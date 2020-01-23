# ARIsTEO

<img src="./Logo.png" alt="ARIsTEO logo" width="48">

ARIsTEO (AbstRactIon based TEst generatiOn) is a novel testing framework that generates faulty test inputs for CI-CPS models in a automatic manner.
ARIsTEO is based on an approximation-refinement loop.
It is a comprehensive framework that uses different existing tools and combines them to solve the test case generation problem in an effective manner.
Specifically, ARIsTEO learns from the CI-CPS model a non-CI-CPS surrogate model, which is used for generating a (faulty) input.
As the faulty input generated for the surrogate model can be spurious, a check on the original model is used to verify whether input is also faulty on the original model. If the input is spuriously faulty, the surrogate model is refined. Otherwise the faulty input is returned.

# Content description
- ARIsTEO: contains ARIsTEO and the software we had developed for this project
- RQs: contains the scripts necessary to replicate our experiments
- Benchmarks: contains the benchmarks that are considered in our study
    * We cannot share the XXXEx case study as it is part of a non disclosure agreement (NDA)
- Results: contains the results of our experiments and the scripts that generate the results reported in the paper
- Tutorial: contains a simple example - a pendulum -  that shows how ARIsTEO works

## Installation instructions
- open the folder ARIsTEO with Matlab
- add the folder ARIsTEO and all of its subfolders on your classpath (right click on the folder > add to path > selected folder and subfolders)
- open the folder ``staliro``
- run the command ``setup_staliro``

## Running ARIsTEO
After ARISTEO is performed type "help aristeo".
Note that ARIsTEO has the same interface of S-Taliro.

###############################################################
# Have fun! Install ARIsTEO and take a look at the tutorial
###############################################################
