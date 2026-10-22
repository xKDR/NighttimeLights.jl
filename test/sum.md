# test layout

two types of test: 
- mechanical: bookkeeping. shapes, unusual inputs, types, masks, agreement between implementations.
- logic: methods validation. statistical bounds on synthetic data. 

### types of test: 
property = Supposition library, generated inputs. 
example = fixed inputs
Monte Carlo = seeded, bounds on medians/rates

## mechanical

### f_apply.jl
- `applies_only_inside_mask`
- `default_mask_applies_everywhere`
- `masks_by_multiplication`
- `default_mask_is_identity`

### readnl.jl
- `sorts_and_filters_by_date`
- readers on synthetic tifs (example)

### example.jl
- `load_example` (example)

### data_cleaning/na_recode.jl
- `marks_cloudy_months_in_cube`
- `accepts_cube_without_missing_eltype`
- `marks_cloudy_months_in_image`
- `custom_replacement`

### data_cleaning/replace_negative.jl
- `drops_negatives_in_place`
- `custom_replacement`
- `drops_values_above_ceiling`
- `float16_conversion_stays_finite`

### data_cleaning/interpolation.jl
- `too_gappy_series_become_zeros`
- all-`Missing` vector (example)
- `fills_every_gap_within_neighbours`
- `reconstructs_a_line`

### data_cleaning/outlier_removal.jl
- `only_adds_missings`
- `keeps_constant_series`
- `removes_a_spike`
- `masks_only_lit_pixels`
- `higher_cutoff_keeps_more`

### data_cleaning/bgnoise.jl
- `lit_iff_last_year_mean_above_threshold`
- `ignores_earlier_months`

### data_cleaning/bias_correction.jl
- `never_raises_above_observed_max`
- `corrects_only_eligible_pixels`

### data_cleaning/full_procedures.jl
- `keep_shape_and_leave_no_missing`
- `dark_region_is_all_zeros`
- `lowmem_matches_PSTT2021`
- `noise_keyword_is_used`
- `clean_complete_matches_PSTT2021`
- Mumbai sample (example)
- `collect_garbage` (example)

### other/weighted_mean.jl
- `zero_without_weighted_observations`
- `lies_within_weighted_observations`
- `invariant_to_scaling_weights`
- `float16_does_not_overflow`

### other/detrend.jl
- `removes_a_linear_trend`
- `residuals_have_zero_mean`
- `keeps_missing_positions`

### other/rank_correlation.jl
- `t_test` known value (example)
- `t_test_falls_as_r_rises`
- `p_value_is_a_probability`

### other/com.jl
- `single_lit_pixel_is_the_centre`
- `invariant_to_scaling_radiance`
- `float16_does_not_overflow`
- Mumbai sample (example)

### other/rings.jl
- `ring_lies_inside_its_disk`
- `disk_is_ring_with_no_hole`
- `centre_lit_only_without_hole`
- tiny radii (example, regression)

### other/date_to_int.jl
- `formats_year_and_month`

## logic

the real attenuation mechanism is unknown, so the tests use a stand-in model.
all logic tests are in logic.jl, in the order below. the model helpers (`cloudiness`,
`cloud_free_days`, `dimming`) are at its top.

model, for month k:

    obs[k]   = truth[k] * dim[k] + e[k]
    truth[k] = L * (1 + g * (k - 1) / 12)
    dim[k]   = 1 - depth * (1 - ncf[k] / 30)
    ncf[k]   = clamp(round(28 - 22 * c[k]) + u[k], 1, 30)
    c[k]     = (1 + cos(2 * pi * (k - 7) / 12)) / 2
    e[k]     ~ Normal(0, sigma^2), sigma = 0.03 * L

- obs: observed radiance, the input to the cleaning
- truth: true radiance, what the cleaning should recover
- L: starting level of the pixel, 10-60
- g: yearly growth rate, 0-0.1 (0 in some tests)
- dim: dimming factor. 1 at ncfobs = 30, 1 - depth at ncfobs = 0
- depth: largest share of radiance lost to clouds, 0.2-0.5
- ncf: cloud-free observations in the month (ncfobs). ~6 in July, ~28 in January
- c: cloudiness. 1 in July (monsoon peak), 0 in January
- u: integer noise, uniform on [-2,2]
- e: Gaussian noise. sigma is fixed at 3% of L, not of the current level

so July reads ~16-40% low (dim = 1 - 0.8 * depth at ncfobs = 6), January ~1-3% low.
the dirty scenes differ: noise is relative, obs = truth * dim * (1 + e)
with e ~ Normal(0, 0.03^2), and some months are set to ncfobs = 0 with obs = -3.

tests check approximate statistical correctness.

how `bias_PSTT2021` picks pixels to correct: a pixel is corrected only when its detrended 
radiance rises with ncfobs, i.e. it is brighter in months with more cloud-free observations, 
which is evidence that clouds dim it. this is decided by a one-sided rank correlation test 
(`rank_correlation_test`) at p < 0.05. pixels outside the mask or more than 90% missing are 
skipped.

null: depth = 0, so there is no dimming. obs = L + e, and ncfobs is seasonal but has nothing to 
do with obs. any correction made there is a false positive.

### detrend_ts (property)
- `keeps_seasonality`: a linear trend + periodic function (seasonality), 2-10 whole years, no
  noise. checks if the output is the periodic function, to rounding. the periodic function is
  a cosine symmetric within each year (peak between June and July), so it has no linear trend
  of its own over whole years. bias correction, the rank correlation test and
  `outlier_variance` all detrend first, so the cycle must be kept.
- `trend_is_removed_with_gaps`: the same periodic function over 72 months, up to 40 months
  missing, plus a random linear trend. missing months break the symmetry, so the fitted line
  takes up part of the cycle and the output is no longer the cycle. checks instead if adding
  the trend changes nothing: the output equals the detrended periodic function alone, with
  `missing` in the same places.

### rank_correlation_test (Monte Carlo, 2000 series of 72 months)
`rank_correlation_test` decides which pixels `bias_PSTT2021` corrects, so it can fail two ways:
correcting pixels clouds do not dim, or skipping pixels that do.
- null: 2000 null-case series. checks if p < 0.05 in 3-7% of them. a correct test at the 5%
  level flags about 5% of null series by chance; with 2000 series, 3-7% is 5% +/- 4 standard
  errors. a higher rate means pixels with no cloud effect get corrected, and the correction
  raises their mean even though nothing needed fixing (see forced lift below).
- power: 2000 series dimmed with depth 0.2, the weakest dimming used in these tests. checks if
  p < 0.05 in more than 98% of them. a lower rate means dimmed pixels are skipped and keep
  their cloud bias.

### bias correction, dimmed pixels (Monte Carlo, 500 pixels)
each pixel: 72 months, L 10-60, depth 0.2-0.5, g = 0 except in "trend kept".
`bias_PSTT2021_pixel` is called directly, so the noise mask, variance mask, Hampel filter and
rank correlation test play no part: this measures the correction alone.
- mean rises: checks if every pixel's corrected mean is above its observed mean. in the model
  clouds can only lower radiance (dim <= 1), so the correction should only raise it; a pixel
  whose mean fell was corrected in the wrong direction.
- share of bias removed: `(mean(out) - mean(obs)) / (mean(truth) - mean(obs))`, 0 if nothing
  is fixed, 1 if the clear-sky level is recovered. checks if the median is 0.8-1.0 and
  fewer than 1% of pixels are below 0.5. the main measure of how much of the cloud
  bias the method undoes.
- no overshoot: checks if at most 1% of pixels end with a mean above mean(truth) + 2 * sigma.
  overcorrecting inflates radiance just as clouds deflate it.
- follows cloud cover: checks if the correction is largest in the cloudiest months, in two
  ways. the rank correlation between each month's change (out - obs) and its ncfobs must have a
  median below -0.8 across pixels. and in every pixel, the mean change in
  months with ncfobs <= 10 must be more than 5x the mean absolute change in months with ncfobs >= 28.
  a correction that adds the same amount to every month gets the mean right and fails both.
- trend kept: g 0-0.1. checks if the absolute slope (per year, as a share of L) barely changes:
  median change within +/-0.005, 95% of pixels lose less than 0.03, none gain more than 0.02.
  without knowing the dimming mechanism the true growth can't be recovered; the method raises
  the level and keeps the observed slope, so growth as a percentage comes out ~g * mean(dim),
  not g. fast growers lose a little more: the cap that resets corrected values above the
  observed maximum to their observed value hits the late, high months. checked by removing the
  cap: the 5th percentile of the slope change moves from -0.021 to -0.0001.

### bias correction, pure noise (Monte Carlo, 20x25 cube)
null case with L = 20, sigma = 0.6.
- false corrections: `bias_PSTT2021` on the whole cube. checks if fewer than 8% of the 500
  pixels are changed. about 5% pass the rank correlation test by chance; with no cloud effect,
  almost nothing should be touched.
- forced lift: `bias_PSTT2021_pixel` called on every null pixel, skipping the rank correlation
  test. checks if the mean rises by ~0.4 * sigma (median 0.2-0.7 * sigma, none above
  2.5 * sigma). the correction fits a spline of detrended radiance against ncfobs and moves each
  month up by the gap between the spline at that month's ncfobs and the spline's maximum. on noise the
  maximum sits above the average, so the correction adds a small upward bias even with nothing
  to fix. the bound is there so a change in this bias is noticed; the rank correlation test
  keeps it to about 5% of pixels.

### full pipelines, dirty scenes (property, 15 scenes per run)
4x4x72 cube. each pixel has its own L 10-60; the scene has one g 0-0.1, one depth 0.2-0.5 and a
noise seed. lit pixels grow and are dimmed, with 3% relative noise. then dirt is added: a dark
row (obs ~ Normal(0, 1), some negative), one gas flare (uniform 0-500), up to 30 lit
pixel-months with ncfobs = 0 (obs = -3), and up to 8 one-month 5x spikes, kept out of the first
and last 12 months. the full pipelines run on it and are compared with the truth. a failure
says something in the chain is wrong; the single-step tests above say where.
- `bias_correction_removes_seasonality`: seasonal amplitude of each lit pixel after detrending
  (range of its 12 month-of-year means, divided by its level), as a ratio to the dimmed
  series' amplitude. checks if the median over pixels is above 0.8 for
  `PSTT2021_conventional`, which has no bias correction, and below 0.4 for `PSTT2021`,
  `clean_complete` and `PSTT2021_lowmem`. the cloud-driven seasonal pattern is the bias, so
  conventional cleaning should leave it and the bias-correcting pipelines should mostly remove it.
- `recovers_true_lights`: checks if each lit pixel's median error against the truth is below
  8% and below 0.6x the conventional pipeline's error.
- `keeps_long_run_growth`: `PSTT2021` only. checks if the median growth over lit pixels lies
  in [g * (1 - depth) - 0.015, g + 0.015]. the lower bound allows the understatement
  described under "trend kept".
- `cleans_the_dirt`: checks, in every pipeline, that no `missing` or negative values remain,
  that the dark row and the flare come out as zeros, and that every spike month ends within
  50% of the truth (a spike left in would be 400% off) with a median below 10%; conventional
  is compared with truth * dim, since it keeps the dimming. for the bias-correcting pipelines
  it also checks that every ncfobs = 0 month is filled within 50% of the truth, median below
  10%. conventional is skipped there: it fills from dimmed neighbours, so the truth is no
  reference.

### bounds checked by breaking code
each broken version below was run against logic.jl, and makes exactly the listed ones fail.
- correction that changes nothing: mean rises, share of bias removed, follows cloud cover,
  forced lift, `bias_correction_removes_seasonality`, `recovers_true_lights` and
  `cleans_the_dirt` fail.
- rank correlation test that always returns p = 0.01: false corrections and null fail.
- correction that removes only half the bias: share of bias removed,
  `bias_correction_removes_seasonality`, `recovers_true_lights` and `cleans_the_dirt` fail.
- correction that adds the same amount to every month: both follows cloud cover checks,
  `bias_correction_removes_seasonality`, `recovers_true_lights` and `cleans_the_dirt` fail.
- conventional pipeline in place of the bias-correcting ones (`bias_PSTT2021` returns its input):
  `bias_correction_removes_seasonality`, `recovers_true_lights` and `cleans_the_dirt` fail.
