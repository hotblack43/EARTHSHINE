#uv run align_coadd_then_center_ROBUSTER.py   --align-iters 2 --r-min 125 --r-max 150 --radius-quantile 0.95 --verbose   --dark-list ./allDARKframes.txt
uv run align_coadd_then_center_INT_or_FLOAT_shifts_AVERAGE_SCI_DARK_DIFF_DARKFIRST.py   --align-iters 4 --r-min 125 --r-max 155  --verbose   --dark-list ./allDARKframes.txt
