# fieldtrip-parallel-work

This repo contains work in progress for Andrew Janke's 2021 [FieldTrip](https://www.fieldtriptoolbox.org/) Parallelization project.

## General Stuff

This is not intended to be a long-lived repo or software project in itself: it documents the work done for a specific work project in 2021. Useful code and results will be either upstreamed to FieldTrip itself or spun out to a separate repo, if they're considered sufficiently valuable.

The code here is intended to work as far back as Matlab R2016b, but was mostly tested on R2019b.

## Repo Contents

### Tutorial and Example Functions

The main contents of this repo are the code from the [FieldTrip Tutorials](https://www.fieldtriptoolbox.org/tutorial/) converted to functions which can be run without arguments, and with a common environment configuration, to support benchmarking of the FieldTrip code.

These are effectively versions of the `test_tutorial_*.m` test scripts in the [FieldTrip test/ directory](https://github.com/fieldtrip/fieldtrip/tree/master/test) which can be run outside of the environment of the Donders network.

These tutorial functions are structured so that they can be run without depending on your Matlab session's current working directory. This allows you to run them while you're `cd`'ed to their source code while working on them, or `cd`'ed to the FieldTrip repo to look at its code easily, or anywhere else. This means that the path references in the code have all been modified to replace relative paths with full paths using `ft_tut_datadir` (a new function introduced specifically for this scaffolding code).

I have left the tutorial code pretty much unmodified. I have not attempted to make the code Mlint-clean.

The tutorial functions do not return anything useful. If you want to see their results, you will generally want to put a Matlab debugger breakpoint at the final `end` of the function and then run it.

Running the tutorial functions may have the following side effects:

* They may use blocking GUI functions, so manual interaction may be required to complete them.
* They may leave new figures up.
* They may write or delete any data under `ft_tut_workdir`.

The function sets are:

* `ft_tut_*` - Based on the [FieldTrip Tutorials](https://www.fieldtriptoolbox.org/tutorial/).
* `ft_ex_*` - Based on the [FieldTrip Example Scripts](https://www.fieldtriptoolbox.org/example/).
* `ft_tut_datadir`, `ft_tut_workdir` - Configuration functions for this code.

## Usage

All the Matlab code is in the `Mcode` directory. Add that to your Matlab path. You'll also need FieldTrip itself.

The data used by the tutorial code is sourced from the FieldTrip FTP site at <ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/tutorial/>. (Note that some modern browsers do not support FTP, so you'll need a separate FTP client.) You'll need to download all the relevant data files for the tutorial code you want to run to a directory on your disk and unzip them. Then, to let this repo's tutorial code know where they are, run `ft_tut_datadir('/path/to/my/datadir')`. This data set is kind of large; like 45 GB once unzipped.

Some additional data used by some tutorial functions is found at <ftp://ftp.fieldtriptoolbox.org/pub/fieldtrip/workshop>. If you download this locally, set the path to it with `ft_tut_workshopdir('/path/to/my/workshop/copy')`.

## Author and Project

Developed by [Andrew Janke](https://apjanke.net).

The project website is the [this apjanke/fieldtrip-parallel-work repo on GitHub](https://github.com/apjanke/fieldtrip-parallel-work). Andrew's work on parallelizing FieldTrip itself can be found  on [the apjanke/fieldtrip fork repo on GitHub](https://github.com/apjanke/fieldtrip) on the [apjanke/parfor-ify branch](https://github.com/apjanke/fieldtrip/tree/apjanke/parfor-ify).

Coding powered by "The Roar of Love" by 2nd Chapter of Acts.
