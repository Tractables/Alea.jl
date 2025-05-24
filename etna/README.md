# ICFP 2023 Artifact

Name: Etna: An Evaluation Platform for Property-Based Testing

## Artifact Instructions

### Orientation

The contents of this `README` focus on showing you how to reproduce the
experiments discussed in our paper. Beyond artifact evaluation, we hope that our
system will be useful to researchers who want to empirically evaluate their
property-based testing strategies. As such, we also have `DOCUMENTATION.md`
which describes in much more detail how this tool is structured and what users
should do if they want to run their own experiments or otherwise extend it.

Please see `DOCUMENTATION.md` to learn more about these details.

### Language Dependencies

**These steps should already be completed in the VM.**

1. For Python, install version 3.10.5,
   and make sure `python3` points to this version.

2. For Haskell, install `stack`:

    ```
    $ curl -sSL https://get.haskellstack.org/ | sh
    ```

3. For Coq, use `opam` to install OCaml compiler version `4.10.0+afl`
   and pin Coq version `8.15.0`.

### Package Dependencies

**These steps should already be completed in the VM.**

1. For Python, make sure you have `pip` installed.

    Then, run the following commands:

    ```
    $ cd ~/etna
    $ make install
    ```

2. For Haskell, run the following commands:

    ```
    $ cd ~/etna/bench-suite/Haskell/BST
    $ stack ghci src/Impl.hs
    ```

    Doing this for the first time will force `stack` to install GHC 9.0.2 and
    the required packages.

3. For Coq, we need a newer version of QuickChick. Clone the repo
   [here](https://github.com/QuickChick/QuickChick), checkout the
   `etna` branch, and follow the instructions for installing from
   source, including `make install` and `make install-fuzz`.

### Experiment Reproduction

**Start here if you're in the VM.**

All of the below should be done in the `etna` folder, so please first

```
$ cd etna
```

Some things to be aware of:

-   We recommend briefly reading the setup described in the corresponding
    experiment section in the paper to get a sense of what each experiment is
    evaluating, since we did not repeat that information here.

-   Running our experiments in full as we did originally for the paper would
    take several days in total. As such, we offer scaled-down versions that
    should demonstrate the same trends but take drastically less time. The
    `Makefile` is configured to run these versions by default.

-   Experiment scripts should be easily resumable; data will not be re-collected
    unless it is deleted.

-   There are two experiments that use prior results when the same strategy is
    evaluated again (to save time). So, experiment 4.1 must be completed before
    4.3, and 5.1 before 5.2.

#### Section 4.1: Comparing Frameworks.

Estimated time for scaled-down experiment: around 4 hours.

-   Originally, we ran each strategy on each task for 10 trials, even if the
    strategy could not solve the task. This is the most time consuming component
    — running until the 60+ second timeout repeatedly. So, the scaled-down
    version "short-circuits" as soon as a strategy fails. i.e., If QuickCheck
    times out on the 3rd trial, the 4th through 10th trials are not run.

    This has no impact on the majority of the data collected and analyzed for
    this experiment, since we find a task to be (completely) solved only if it
    was solved on all trials. The only piece that will be lost is the discussion
    in lines 269 to 278 about partially solved tasks.

-   Additionally, the scaled-down version only runs 1 trial for the
    deterministic strategies (LeanCheck and SmallCheck). We ran 10 trials in the
    original since there could be some small variations in time, but for the
    purposes of this artifact we can just run 1 trial.

One more thing to note:

-   The enumeration strategy LeanCheck is
    [documented](https://github.com/rudymatela/leancheck/blob/master/doc/memory-usage.md)
    to be quite memory intensive when run for prolonged periods of time.

    We ran our experiments on a powerful server (300+GB of memory), so we did
    not run into problems previously, but the typical machine will not be
    equipped to handle this, which we did not realize until we tried to run the
    experiments on the VM locally.

    We'll make sure to mention the specs of our servers and the implications
    for LeanCheck's performance in the camera-ready.

    In the meantime, we've provided a less space-intensive version that changes
    the timeout for LeanCheck to 10 seconds instead of 60. We chose 10 since it
    is the boundary between the second-highest and highest buckets in the task
    bucket chart.

    We will note in the discussion that follows the places where this will cause
    some deviations from the paper's data.

Run this to collect the data for this experiment: (Don't worry about the
OpenBLAS warning if you see it on the VM.)

```
$ make collect4.1
```

The raw JSONs will be saved in `data/4.1`.

Run this to analyze the data for this experiment:

```
$ make analyze4.1
```

Points of comparison with the paper:

Figure 1.

-   Please view the charts in `figures/fig1`. There should be four charts, named
    `BST`, `RBT`, `STLC`, `FSUB`. These charts correspond with those depicted in
    Fig. 1 from the paper.

    These are task bucket charts (described in Section 2.4), where strategies
    with better bug-finding power will visually have a darker color presence.
    For example, bespoke QuickCheck is especially fast, so there should be a
    nearly full black bar in the fourth row of each chart. Naive SmallCheck is
    especially slow, so there should be relatively little pink in each chart.

-   Mild deviations in the number of tasks in each bucket are to be expected,
    both due to variations in machine speed and the inherent randomness of some
    of the generation strategies.

-   As mentioned above, the artifact version runs LeanCheck for only 10 seconds,
    so for `FSUB.png`, we expect not to see the faint purple tasks and instead
    to see around 14 unsolved tasks.

Observation —
"The bespoke strategy outperforms the naive strategies along multiple axes."

-   We also print a table of solve rates.

    As mentioned in line 252, bespoke QuickCheck (the `Correct` strategy)
    should solve all tasks. As mentioned in line 253, naive QuickCheck
    (the `Quick` strategy) should fail to solve approximately 43 tasks.

Observation —
"LeanCheck substantially outperforms SmallCheck."

-   As mentioned in line 259, SmallCheck (`Small`) should have around a 35%
    solve rate. LeanCheck (`Lean`) would normally have a 82% solve rate, but
    because of the adjusted timeout, we expect around 76% instead.

#### Section 4.2: Exploring Size Generation.

Estimated time for scaled-down experiment: around 1.5 hours.

-   While we originally ran 100 trials for each task, the analysis for the
    experiment only focuses on three tasks. So, this version runs the full 100
    trials for the three tasks and 10 trials for the other tasks.

Commands are the same as before but with 4.2 instead, e.g.

```
$ make collect4.2
$ make analyze4.2
```

Points of comparison with the paper:

-   Please view the chart `figures/figure2.png`. This should resemble Fig. 2
    from the paper, though with colors instead of numbered labels.

    As in the paper, the task #1 trendline (red) should have the steepest upward
    trajectory. The task #2 trendline (green) should also go up, but less
    steeply. The task #3 trendline (blue) should be mostly flat and near the
    y-axis.

-   Note that the precise y-axis numbers may differ from the paper — there is
    variance due to the random nature of these generation strategies. However,
    the relative trends described above should hold.

#### Section 4.3: Enumerator Sensitivity.

Estimated time for scaled-down experiment: around 1 hour.

-   The key result and ensuing discussion is about the observation that
    SmallCheck is very sensitive to a reversal of the parameter orders, so in
    the scaled-down version, we run only SmallCheck.

-   As before, we run only 1 trial since it is deterministic.

Commands are the same as before but with 4.3 instead, e.g.

```
$ make collect4.3
$ make analyze4.3
```

Please note that the collection script for this experiment generates only the
new data needed; the analysis script will draw upon some of the data collected
for SmallCheck in 4.1.

Points of comparison with the paper:

-   The analysis script will output several pices of information. First, the
    number of tasks solved by SmallCheck in the original but not in the reversed
    should be 0.

-   Second, the number of tasks solved in the reversed but not in the original
    should be 17 (line 389). The times to failure for these tasks are also
    printed in the table. These times should be fairly low — many will be less
    than 1 second.

#### Section 5.1: Comparison of Fuzzers, Derived Generators, and Handwritten Generators.

Estimated time for scaled-down experiment: around 8 hours.

-   Analogously to in 4.1, we short-circuit the 10 trials as soon as a timeout
    is encountered. This will not have an effect on the bulk of the data for
    this experiment, with the exception of no longer being able to generate Fig.
    4, which deals with partially solved tasks.

Other commands are the same as before but with 5.1 instead, e.g.

```
$ make collect5.1
$ make analyze5.1
```

If you get an error about the QuickChick version, see 5.2.

Points of comparison with the paper:

-   Please view the charts in `figures/fig3`. There should be four charts, named
    `BST`, `RBT`, `STLC`, `IFC`. These charts correspond with those depicted in
    Fig. 3 from the paper.

-   While some variance is expected, the general trends should be consistent
    with the paper. For example, the specification-based generator (in red) and
    bespoke generator (in black) should generally outperform the other
    strategies, and they should perform on par with each other.

    The fuzzers (in orange in (a) through (c) and in orange and green in (d))
    may be slightly slower than the type-based generator (on the top row, in
    blue), but they will be able to solve more tasks than the type-based
    generator in the IFC workload, which has the sparsest precondition.

    Note that fuzzers especially have high variance (which is noted in the
    paper), so the exact number of tasks solved and the proportions of the tasks
    in each bucket may deviate from the paper.

#### Section 5.2: Validation and Improvement of Fuzzers.

Estimated time for scaled-down experiment: around 3 hours.

-   Analogously to before, we short-circuit the 10 trials as soon as a timeout
    is encountered.

One of the strategies in this experiment uses an older (and worse) version of
QuickChick, since the purpose of the experiment is to notice how the changes to
the implementation improved the bug-finding performance. (There is also a change
to the max bound on the number of tests, which the script will apply for you,
since this older version had overflow problems.)

To switch to this older version, run

```
$ make switchold
```

Other commands are the same as before but with 5.2 instead, e.g.

```
$ make collect5.2
$ make analyze5.2
```

After you are done with this experiment, make sure to switch back to the newer
version, especially if you need to rerun any parts of 5.1.

```
$ make switchnew
```

The collection script for this experiment generates only the new data needed;
the analysis script will draw upon data collected in 5.1.

Points of comparison with the paper:

-   Please view the charts in `figures/fig5`. There should be three charts, named
    `BST`, `RBT`, `STLC`. These charts correspond with those depicted in
    Fig. 5 from the paper.

-   Visually, it should be clear that the lower strategy (tuned FuzzChick)
    significantly outperforms the upper strategy (original FuzzChick), which
    solves very few tasks overall.

## QEMU Instructions

The ICFP 2023 Artifact Evaluation Process is using a Debian QEMU image as a
base for artifacts. The Artifact Evaluation Committee (AEC) will verify that
this image works on their own machines before distributing it to authors.
Authors are encouraged to extend the provided image instead of creating their
own. If it is not practical for authors to use the provided image then please
contact the AEC co-chairs before submission.

QEMU is a hosted virtual machine monitor that can emulate a host processor
via dynamic binary translation. On common host platforms QEMU can also use
a host provided virtualization layer, which is faster than dynamic binary
translation.

QEMU homepage: https://www.qemu.org/

### Installation

#### OSX

`brew install qemu`

#### Debian and Ubuntu Linux

`apt-get install qemu-kvm`

On x86 laptops and server machines you may need to enable the
"Intel Virtualization Technology" setting in your BIOS, as some manufacturers
leave this disabled by default. See Debugging.md for details.

#### Arch Linux

`pacman -Sy qemu`

See the [Arch wiki](https://wiki.archlinux.org/title/QEMU) for more info.

See Debugging.md if you have problems logging into the artifact via SSH.

#### Windows 10

Download and install QEMU via the links at

https://www.qemu.org/download/#windows.

Ensure that `qemu-system-x86_64.exe` is in your path.

Start Bar -> Search -> "Windows Features"
-> enable "Hyper-V" and "Windows Hypervisor Platform".

Restart your computer.

#### Windows 8

See Debugging.md for Windows 8 install instructions.

### Startup

The base artifact provides a `start.sh` script to start the VM on unix-like
systems and `start.bat` for Windows. Running this script will open a graphical
console on the host machine, and create a virtualized network interface.
On Linux you may need to run with `sudo` to start the VM. If the VM does not
start then check `Debugging.md`.

Once the VM has started you can login to the guest system from the host.
Whenever you are asked for a password, the answer is `password`. The default
username is `artifact`.

```
$ ssh -p 5555 artifact@localhost
```

You can also copy files to and from the host using scp.

```
$ scp -P 5555 artifact@localhost:somefile .
```

### Shutdown

To shutdown the guest system cleanly, login to it via ssh and use

```
$ sudo shutdown now
```

### Artifact Preparation

Authors should install software dependencies into the VM image as needed,
preferably via the standard Debian package manager. For example, to install
GHC and cabal-install, login to the host and type:

```
$ sudo apt update
$ sudo apt install ghc
$ sudo apt install cabal-install
```

If you really need a GUI then you can install X as follows, but we prefer
console-only artifacts whenever possible.

```
$ sudo apt install xorg
$ sudo apt install xfce4   # or some other window manager
$ startx
```

See Debugging.md for advice on resolving other potential problems.

If your artifact needs lots of memory you may need to increase the value
of the `QEMU_MEM_MB` variable in the `start.sh` script.

When preparing your artifact, please also follow the [Submission
Guidelines](https://icfp23.sigplan.org/track/icfp-2023-artifact-evaluation#Submission-Guidelines).
