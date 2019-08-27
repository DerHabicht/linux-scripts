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

GITIGNORE=$(cat <<EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with \`go test -c\`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
vendor/
EOF
)

HEALTH=$(cat <<EOF
package controllers

import (
	"github.com/gin-gonic/gin"
	"net/http"
)

type ServiceStatus struct {
	Services map[string]bool \`json:"status"\`
	Version  string          \`json:"version"\`
}

type HealthController struct {
	Status ServiceStatus
}

// NewHealthController initializes a HealthController.
func NewHealthController() HealthController {
	return HealthController{
		Status: ServiceStatus{
			Services: make(map[string]bool),
			Version:  "0.1.0",
		},
	}
}

// Healthcheck handler.
// @Summary Check to assure that the service is running.
// @Description Healthcheck endpoint. Reports which statuses are currently
// @Description running and the current API\'s version number. If critical
// @Description services are running, it will return 200. If any of the
// @Description critical services are down, then the endpoint will return 503.
// @Success 200 {object} controllers.ServiceStatus
// @Failure 503 {object} controllers.ServiceStatus
// @Router /health [get]
func (h HealthController) Check(c *gin.Context) {
	h.Status.Services["endpoint"] = true

	c.JSON(http.StatusOK, h.Status)
}
EOF
)

LICENSE=$(cat <<EOF
MIT License

Copyright (c) $(date +%Y) Robert Hawk

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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

        health := controllers.NewHealthController()
		{
			v1.GET("/health", health.Check)
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

# Adapted from this template: https://gist.githubusercontent.com/PurpleBooth/109311bb0361f32d87a2/raw/8254b53ab8dcb18afc64287aaddd9e5b6059f880/README-Template.md
README=$(cat <<EOF
# $1 $2

One Paragraph of project description goes here

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites
  - Go 1.12.5 (or later)
  - Postgres 11.4 (or later)
  - [Dep](https://github.com/golang/dep)
  - [Migrate](https://github.com/golang-migrate/migrate)
  - [Swaggo CLI](https://github.com/swaggo/swag)

### Installing
  1. \`git clone git@github.com:$1/$2.git\`
  2. \`psql -U postgres -c "CREATE DATABASE $2_development;"\`
  3. \`migrate -source file://db/migrations -database postgres://localhost:5432/$2_development?sslmode=disable up\`
  4. \`go run db/seed/seed.go\`
  5. \`go run main.go\`

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

\`\`\`
Give an example
\`\`\`

### And coding style tests

Explain what these tests test and why

\`\`\`
Give an example
\`\`\`

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Gin](https://gin-gonic.com) - API framework
* [Dep](https://golang.github.io/dep/) - Dependency Management
* [Postgres](https://postgresql.org) - Database
* [Migrate](https://github.com/golang-migrate/migrate) - Database Migrations
* [Swaggo](https://github.com/swaggo/swag) - API Documentation

## Contributing
Before committing, be sure to:
 1. Use [Git Flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
 2. [Sign your commits](https://git-scm.com/book/ms/v2/Git-Tools-Signing-Your-Work)
 3. Run \`gofmt -s\'
 4. Run \`swag init\`

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Robert Hawk** - *Initial work* - [DerHabicht](https://github.com/DerHabicht)

See also the list of [contributors](https://github.com/$1/$2/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
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
 
echo "Creating .gitignore"
echo "$GITIGNORE" > .gitignore
git add .gitignore
echo "Creating LICENSE"
echo "$LICENSE" > LICENSE
git add LICENSE
echo "Creating README.md"
echo "$README" > README.md
git add README.md

echo "Creating main.go"
echo "$MAIN" > main.go
git add main.go
 
echo "Creating config directory"
mkdir config
echo "Creating config/config.go"
echo "$CONFIG" > config/config.go
git add config/config.go

echo "Creating controllers directory"
mkdir controllers
echo "Creating controllers/health.go"
echo "$HEALTH" > controllers/health.go
git add controllers/health.go

echo "Creating db directory"
mkdir db
echo "Creating db/db.go"
echo "$DB" > db/db.go
git add db/db.go
echo "Creating db/migrations directory"
mkdir db/migrations
touch db/migrations/.gitkeep
git add db/migrations/.gitkeep
echo "Creating db/seed directory"
mkdir db/seed
echo "Creating db/seed/development.yml"
touch db/seed/development.yml
git add db/seed/development.yml
echo "Creating db/seed/seed.go"
echo "$SEED" > db/seed/seed.go
git add db/seed/seed.go

echo "Creating models directory"
mkdir models
echo "Creating models/models.go"
echo "$MODELS" > models/models.go
git add models/models.go
 
echo "Initializing Dep"
dep init
echo "Initializing Swaggo"
swag init
git add docs/docs.go
git add docs/swagger.json
git add docs/swagger.yaml
dep ensure
echo "Refreshing Dep"
git add Gopkg.lock
git add Gopkg.toml

git commit -m "Initial commit"
git flow init

echo "Creating development database"
psql -U postgres -c "CREATE DATABASE $2_development;"
