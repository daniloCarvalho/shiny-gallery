
### Shiny Gallery ###

The Shiny Gallery contains a wide variety of example applications that demonstrate features and techniques useful to Shiny developers. You can access the gallery at [http://shinygallery.com](http://shinygallery). 

This repository contains the source code for the Gallery website. This code as well as the code for the examples in the gallery are published using the [MIT license](http://opensource.org/licenses/MIT) to permit broad re-use in both commercial and open-source contexts.

### Contributing to the Gallery ###

Contributions to the Gallery are welcome and encouraged! You can submit a contribution in one of two ways:
 
1. Post to the Gallery [issue tracker](https://github.com/rstudio/shiny-gallery/issues/new). The issue needs to include a link to where the application is hosted on the web (the RStudio hosting service [ShinyApps](http://www.shinyapps.io/signup.html) is a good choice for this) as well as a link to the application's source code (e.g. a [gist](http://defunkt.io/gist/) containing the source code).

2. Fork and clone the Gallery repository and send us a pull request with your contribution (more details on doing this below).

Note that if you are not experienced with creating pull requests already it might be simpler to start by posting contributions as issues. In either case, there are a few guidelines that contributions should meet:

1. They should clearly demonstrate one or two concepts or techniques with a minimum of additional scaffolding code.

2. Source code should be formatted at a width of no more than 65 characters (to facilitate side-by-side viewing of code and application).

3. They should include a `DESCRIPTION` file with metadata about the application and a `Readme.md` file with a short (2 or 3 sentence) description of the application. 

Here's an example `DESCRIPTION` file:

```yaml
Version: 1.0
Type: ShinyShowcase
Title: Hello Shiny!
Author: RStudio, Inc.
AuthorUrl: http://www.rstudio.com/
License: MIT
Tags: getting-started
DisplayMode: Showcase
```

The Gallery takes advantage of a new feature of Shiny called showcase mode which displays applications along with their source code. **IMPORTANT NOTE**: Showcase mode is currently available only on a development branch of Shiny. To install this version of Shiny:

```r
devtools::install("rstudio/shiny", ref = "feature/showcase-mode")
```

Once a `DESCRIPTION` file similar to the above is in place, your app will start in showcase mode by default. You can force it to run normally by appending `?showcase=0` to the URL.


### Adding an Appliation to the Gallery ###

If you want to submit a contribution as a pull request rather than an issue, you'll need to fork and clone this repository and then import your application using the Gallery import utility. This section provides detailed on instructions on how to do this.

#### Fork and Clone the Repository ####

If you want to submit an application to the Gallery as a pull request you should start by forking and cloning the repository, then creating a new branch for your submission. To fork the repository make sure you are logged into Github and then visit this link:

```
https://github.com/rstudio/shiny-gallery/fork
```

Once you've created your fork, clone it to your local development machine and associate your clone with the `shiny-gallery` upstream repository . For example:

```bash
git clone git@github.com:<username>/shiny-gallery
cd shiny-gallery
git remote add upstream https://github.com/rstudio/shiny-gallery
git fetch upstream
```

*NOTE*: Be sure to substitute your Github username for the `<username>` token in the above example.

For more details on forking Github repositories see [this article](https://help.github.com/articles/fork-a-repo) on the Github website.

#### Install Dependencies ####

To run the Shiny Gallery locally you need to be on Linux or Mac OS X. You also need to install some dependencies. These dependencies include several Ruby libraries. To isolate these libraries from others on your system it's strongly recommended that you first install [RVM](https://rvm.io/) (Ruby Version Manager).

Once you've installed RVM you should execute the following from the root directory of the repository: 

```bash
$ _dependencies/install
```

This script installs the Ruby bundles [jekyll](http://jekyllrb.com/) and [gist](http://defunkt.io/gist/), the R [downloader](http://cran.rstudio.com/web/packages/downloader/index.html) and [yaml](http://cran.rstudio.com/web/packages/yaml/index.html) packages, as well as the [phantom.js](http://phantomjs.org/) utility (which is used for capturing thumbnails of Shiny applications).

It's recommended that you run `gist --login` after installing dependencies, so that the import script can automatically create gists for you. 

#### Create the Application ####

To start work on a new Gallery application you should create a Git branch for the application (this branch will eventually be submitted as a pull request). For example, to create a branch for an application named `animiated-slider`:

```bash
git checkout -b app/animated-slider
git push -u origin app/animated-slider
```

Source code for Gallery applications can be stored anywhere, but it's most convenient to store it within the Gallery Github repo itself. This is done within the `src/apps` directory. For example, to create the directory for the `animated-slider` application:

```bash
mkdir src/apps/animated-slider
```

You can now work on your application within the `src/apps/animated-slider` directory until you are ready to submit it to the Gallery.

#### Deploy the Application ####

After your happy with the new example application you should deploy it to the web. The RStudio [ShinyApps](http://www.shinyapps.io/signup.html) service is a good way to do this. Once you've setup a ShinyApps account and installed the `shinyapps` R package, deploying the application from R is as simple as this:

```R
shinyapps::deployApp()
```

#### Perform the Import ####

To import an application you run the `import.R` script from within the `_scripts` folder. It takes two parameters: the file path from which the code was deployed, and the full URL to the deployed application. For instance: 

```bash
$ _scripts/import.R src/apps/animated-slider http://gallery.shinyapps.io/animated-slider
```

The import script will examine the application's `DESCRIPTION` file, verify that it has the required entries, and generate a thumbnail of the application using phantom.js. Note that you can also provide your own thumbnail by including a file named `thumbnail.png` in the application's directory (thumbnail dimensions should be approximately 910x660 pixels).

If the code for the app you wish to import is already hosted somewhere and you'd like the gallery to point there instead of creating a gist (described below), supply the URL as a third parameter to `import.R`. This is also necessary if you want to include folders in your code, since gists can't contain folders.

*NOTE*: The import script does not attempt to verify that the deployed application matches the code supplied, and no error will be generated if they don't match. Be sure you're supplying the correct path.

If all goes well then two files will be generated by the import. For example:

```
_posts/2013-12-20-animiated-slider.md
images/thumbnails/animiated-slider.png
```

##### Source Code Gist #####

In addition to adding a link to your application to the Gallery, the import utility will also create a [gist](https://gist.github.com/) containing your application's source code. All `.R` files in the application's directory will be included.

The gist is created using the Ruby gist gem, which by default creates an anonymous gist. If you'd like to link the gist to your own Github account then login to Github [as described here](http://defunkt.io/gist/#Login) before running the import utility.

Note that the import utility cannot update anonymous gists, so if you use anonymous gists, a new one will be created every time you update your application. 

#### Preview Your Changes ####

After you've imported your application you'll want to run the Gallery locally to preview the changes. To do this you can execute the following from the root directory of the repository:

```bash
$ jekyll serve --watch
```

This will run a local web server that can be accessed at `http://localhost:4000`. Note that the `--watch` parameter is included so that the website is automatically rebuilt when files changes, so if you re-run your import you need only refresh the browser as opposed to stopping and restarting the local web server.

#### Send the Pull Request ####

To send a pull request with your new application, you first push it to Github:

```bash
git checkout feature/animated-slider
git push 
```

You then visit your fork of the `shiny-gallery` repository on the web and submit the pull request from there. We'll provide any required feedback on the pull request and then add it to the Gallery.

#### Updating Existing Applications ####

Updating existing applications is done in the same way as importing new ones--just run `import.R` and supply the code and deployment path. 

Assuming you haven't changed the title of the application, `import.R` will re-read the DESCRIPTION file and propagate updates to any fields, create or update the gist, update the thumbnail, and regenerate the post `.md` file. 

### License ###

The source code for this website is Copyright (c) 2013-2014 RStudio, Inc. and made available under the MIT license. Individual Gallery applications are owned by their authors and also available under the MIT license.

```
The MIT License (MIT)

Copyright (c) 2013-2014 RStudio, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

