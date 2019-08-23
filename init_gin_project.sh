CONFIG=$(cat <<EOF
package config

import (
	"github.com/spf13/viper"
	"github.com/subosito/gotenv"
)

func init() {
	_ = gotenv.Load()
	viper.AutomaticEnv()

	viper.SetDefault("ENV", "development")
	viper.SetDefault("URL", "localhost:3000")
	viper.SetDefault("DB_HOST", "localhost")
	viper.SetDefault("DB_USER", "postgres")
	viper.SetDefault("DB_NAME", "$2_development")
	viper.SetDefault("DB_PASSWORD", "postgres")
}
EOF
)

# TODO: Update the DB.Close() line
DB=$(cat <<EOF
package db

import (
	"fmt"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
	"github.com/spf13/viper"
)

var DB *gorm.DB = nil

func init() {
	var err error = nil

	connectionStr := fmt.Sprintf(
		"host=%s dbname=%s user=%s password=%s sslmode=disable",
		viper.GetString("DB_HOST"),
		viper.GetString("DB_NAME"),
		viper.GetString("DB_USER"),
		viper.GetString("DB_PASSWORD"),
	)

	// TODO: Figure out how to add defer DB.Close()
	DB, err = gorm.Open("postgres", connectionStr)
	if err != nil {
		panic(fmt.Sprintf("Unable to establish database connection: %v", err))
	}
}
EOF
)

HEALTH=$(cat <<EOF
package controllers

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type ServiceStatus struct{
	Status string \`json:"status"\`
}

type HealthController struct{
}

// Healthcheck handler.
// @Summary Check to assure that the service is running.
// @Description A no-op endpoint that will return a 200. This is a very basic healthcheck and will not verify that
// @Description services such as the database are currently running.
// @Success 200 {object} controllers.ServiceStatus
// @Router /health [get]
func (h HealthController) Up(c *gin.Context) {
	s := ServiceStatus{
		Status: "UP",
	}
	c.JSON(http.StatusOK, s)
}
EOF
)

SEED=$(cat <<EOF
package main

import (
	"fmt"
	"github.com/romanyx/polluter"
	"github.com/spf13/viper"
	_ "github.com/$1/$2/config"
	"github.com/$1/$2/db"
	"os"
)

func main() {
	p := polluter.New(polluter.PostgresEngine(db.DB.DB()))
	data := fmt.Sprintf("db/seed/%s.yml", viper.GetString("ENV"))
	f, err := os.Open(data)
	if err != nil {
		panic(err)
	}

	err = p.Pollute(f)
	if err != nil {
		panic(err)
	}
}
EOF
)

MAIN=$(cat <<EOF
package main

import (
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	_ "github.com/$1/$2/config"
	"github.com/$1/$2/controllers"
	_ "github.com/$1/$2/db"
	_ "github.com/$1/$2/docs"
)

// @title $1 $2
// @version 0.1.0
// @description UPDATE DESCRIPTION FIELD

// @contact.name UPDATE CONTACT NAME
// @contact.email UPDATE CONTACT EMAIL

// @license.name MIT License
// @license.url https://opensource.org/licenses/MIT

// @host UPDATE HOST
// @BasePath /api/v1
func main() {
	router := gin.Default()
	v1 := router.Group("/api/v1")
	{
		// Visit {host}/api/v1/swagger/index.html to see the API documentation.
		v1.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

		health := new(controllers.HealthController)
		{
			v1.GET("/health", health.Up)
		}
	}

	_ = router.Run(viper.GetString("url"))
}
EOF
)

MODELS=$(cat <<EOF
package models

import (
	"encoding/json"
	"fmt"
	"time"
)

type ValidationErrors []string

func (v ValidationErrors) Error() string {
	verrs, err := json.Marshal(v)
	if err != nil {
		panic(fmt.Errorf("marshalling of validation errors failed: %v", err))
	}

	return string(verrs)
}

type ModelBase struct {
	ID        uint       \`json:"-" gorm:"primary_key"\`
	CreatedAt time.Time  \`json:"-"\`
	UpdatedAt time.Time  \`json:"-"\`
	DeletedAt *time.Time \`json:"-"\`
}
EOF
)

#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]
then
    echo "Please provide a namespace and project name."
    exit
fi

mkdir "$GOPATH/src/github.com/$1/$2"
if [ "$?" != "0" ]
then
    echo "The directory name $1/$2 is already in use."
    exit
fi

cd "$GOPATH/src/github.com/$1/$2"
git init
 
curl https://raw.githubusercontent.com/github/gitignore/master/Go.gitignore > .gitignore
git add .gitignore
curl https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/mit.txt > LICENSE
git add LICENSE
curl https://gist.githubusercontent.com/PurpleBooth/109311bb0361f32d87a2/raw/8254b53ab8dcb18afc64287aaddd9e5b6059f880/README-Template.md > README.md
git add README.md

echo "$MAIN" > main.go
git add main.go
 
mkdir config
echo "$CONFIG" > config/config.go
git add config/config.go

mkdir controllers
echo "$HEALTH" > controllers/health.go
git add controllers/health.go

mkdir db
echo "$DB" > db/db.go
git add db/db.go
mkdir db/migrations
touch db/migrations/.gitkeep
git add db/migrations/.gitkeep
mkdir db/seed
touch db/seed/development.yml
git add db/seed/development.yml
echo "$SEED" > db/seed/seed.go
git add db/seed/seed.go

mkdir models
echo "$MODELS" > models/models.go
git add models/models.go
 
dep init
swag init
git add docs/docs.go
git add docs/swagger.json
git add docs/swagger.yaml
dep ensure
git add Gopkg.lock
git add Gopkg.toml

git commit -m "Initial commit"
git flow init

psql -U postgres -c "CREATE DATABASE $2_development;"
