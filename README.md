Setup Instructions for Insight Net Workshop 2024
================

Welcome to the Insight Net Workshop 2024 Github Repository. We’ve made
it easy for you to get started with this project, and we’re happy to
help! Please take your time and follow the steps below. If you encounter
any issues or need extra help, feel free to reach out–our volunteers are
available to assist during setup and throughout the workshop.

## 0. System requirements

We assume that you have [R](https://cran.rstudio.com) installed.

We also assume that you use
[RStudio](https://posit.co/download/rstudio-desktop/).

If you’re more familiar with a different IDE (VSCode, Emacs, etc.),
that’s fine

## 1. Download the repository (beginner option)

If you’re new to GitHub or prefer not to use command-line tools, the
easiest way to get started is by downloading the repository as a ZIP
file.

### Steps:

1.  On the [InsightNet Workshop 2024 GitHub
    repository](https://github.com/cmu-delphi/insightnet-workshop-2024).
2.  Click the green <kbd>\<\> Code ▾</kbd> button located at the top
    right of this repository.
3.  In the dropdown menu, select **Download ZIP**.
4.  Once downloaded, extract the ZIP file to a folder on your local
    machine.
5.  Open the extracted folder, and you’re all set!

You can now open the `insightnet-workshop-2024.Rproj` file and start
working with them.

## 1. Clone or fork the repository (advanced options)

If you’re familiar with `git`, cloning or forking the repository is a
more flexible option. This will allow you to stay up to date with the
latest changes and contribute to the project directly.

### Steps for cloning the repo:

<!-- You'll get a local copy of the repository. -->

The RStudio way:

1.  On the [InsightNet Workshop 2024 GitHub
    repository](https://github.com/cmu-delphi/insightnet-workshop-2024).
2.  Click the green <kbd>\<\> Code ▾</kbd> button located at the top
    right of this repository.
3.  Then in RStudio, choose “New project” \> “Version Control” \> “Git”
    and paste the address.
4.  Choose a location on your machine where you want the files to be.
5.  Select “Create Project”.

The Command Line way:

1.  On the [InsightNet Workshop 2024 GitHub
    repository](https://github.com/cmu-delphi/insightnet-workshop-2024).
2.  Click the green <kbd>\<\> Code ▾</kbd> button located at the top
    right of this repository.
3.  Open a terminal or command prompt on your computer.
4.  Navigate to the folder where you want to store the project.
5.  Run
    `git clone https://github.com/cmu-delphi/insightnet-workshop-2024.git`
6.  Once cloning is complete, navigate into the project folder:
    `cd insightnet-workshop-2024`

### Steps for forking the repo (requires a personal GitHub account):

1.  In the top right corner of this GitHub repository, click the grey
    <kbd>⑂ Fork ▾</kbd> button.
2.  Proceed from Step 2 in either the “Cloning” or even “Download Zip”
    options. You’ll just be working from your own remote copy rather our
    version of the materials.

## 2. Install required `R` packages

We will use a <span class="tertiary">lot</span> of packages. We’ve tried
to make it so you can get them all at once (with the right versions)

🤞 We hope this works… 🤞

In RStudio:

``` r
install.packages("pak") # good for installing from non-CRAN sources
pak::pkg_install("cmu-delphi/InsightNetFcast24", dependencies = TRUE)
InsightNetFcast24::verify_setup()
```

Back-up approach:

``` r
install.packages("remotes")
remotes::install_github("cmu-delphi/InsightNetFcast24", dependencies = TRUE)
InsightNetFcast24::verify_setup()
```

Hopefully, you see:

    ✔ You should be good to go!

Ask for help if you see something like:

    Error in `verify_setup()`:
    ! The following packages do not have the correct version:
    ℹ Installed: epipredict 0.2.0.
    ℹ Required: epipredict == 0.1.5.

## ✋ Getting help from our volunteers

If you encounter any issues or would like assistance with setting things
up, don’t hesitate to reach out. We have a fantastic group of volunteers
available who can help guide you through the process.
