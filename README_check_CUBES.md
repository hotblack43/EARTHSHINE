POST cube-build CHECKS.
======================

After building complete cubes they should be checked for 'streaks'
and bad exposures.

Use

uv run detect_straks_cubes_2.py --layer 1

This builds lists of the images (CUBES) with and wothout specific
artefacts. Visuall inspect them -- at least all the 'bad' images, by

uv run triage_cubes.py


it will show each image in log stretch and allow the user to indicate
if the image is good '+' or bad '-', go back 'b' and so on.  This builds
a shell script that can move the

indicated bad images to a BAD/ subdirectory.
