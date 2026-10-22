---
title: 'Foundations for nighttime lights data analysis'
tags:
  - Julia
  - nighttime lights
  - VIIRS
  - remote sensing
  - economic activity
authors:
  - name: Ayush Patnaik
    equal-contrib: true
    affiliation: 1
  - name: Ajay Shah
    equal-contrib: true
    affiliation: 1
  - name: Susan Thomas
    equal-contrib: true
    affiliation: 1
affiliations:
 - name: xKDR Forum, India
   index: 1
date: 8 September 2026
bibliography: paper.bib
---

# Summary

A remarkable development in alternative data is the use of satellites that measure nighttime light radiance. From the early 1990s, Nightlights (NL) has been used to measure economic activity. NL correlates well with standard measures of growth and development [@doll2006mapping], which allows measures of economic growth where existing measures are either unreliable or lack the continuity and/or resolution of constant satellite observation. 

Raw monthly NL files are not analysis-ready. They contain missing observations, negative values, outliers, background noise, and cloud-related attenuation [@uprety2019calibration; @rs9080798; @MaEtal2014_responsesNppViirsNightlightSocioeconomicChina]. As a result, every research team must individually implement preprocessing, often with project-specific scripts. This creates entry barriers and weakens comparability and reproducibility across studies.

# Statement of need

`NighttimeLights.jl` is a Julia package for cleaning and bias-correcting monthly nighttime lights from the Visible Infrared Imaging Radiometer Suite (VIIRS). It provides a transparent and reproducible workflow that implements established methods from the applied literature, including cloud-related attenuation correction [@patnaik2021but; @pearson2002outliers; @guptaEtal2017_analysisViirsDerivedNightlightOverIndia].

The package addresses a practical gap: many papers using NL data rely on individual preprocessing pipelines, making it difficult to reproduce findings or compare outcomes across studies. By consolidating key cleaning steps into one standard package, `NighttimeLights.jl` reduces duplicated effort and standardizes core data preparation.

# State of the field

There are two dominant nighttime-lights products used in applied work: annual DMSP-OLS composites (1992-2013) and monthly VIIRS composites (2012-present). VIIRS has finer temporal and spatial resolution and is now the primary data source for contemporary analysis.

Most empirical NL workflows use combinations of missing-value recoding, outlier removal, and cloud-aware filtering, but implementation details vary across projects. This heterogeneity limits comparability. `NighttimeLights.jl` standardizes these operations while retaining modular control for users.

Several software tools already serve the nighttime-lights community, but they address a different part of the workflow. `blackmarbler` [@marty2024blackmarbler] and its Python counterpart `BlackMarblePy` [@marty2024blackmarblepy] download NASA's Black Marble product and compute zonal statistics for administrative regions; `Rnightlights` [@njoku2019rnightlights] does the same for the NOAA DMSP-OLS and VIIRS composites; and the VIIRS collections in Google Earth Engine [@gorelick2017gee] provide server-side access and aggregation. These tools focus on acquisition and spatial aggregation, and the Black Marble product applies sensor, terrain, and atmospheric corrections upstream at the pixel level. None of them implement a configurable statistical cleaning pipeline for the raw NOAA monthly composites, and none correct the cloud-cover attenuation bias that dominates monthly series in monsoonal regions. Contributing these routines to the existing packages would mean maintaining the same methods across three language ecosystems; providing them as a standalone Julia package, with the cleaning pipeline itself as the unit of reuse, keeps the methods in one place and keeps a cleaned panel reproducible from a single package version.

# Software design

`NighttimeLights.jl` is implemented in Julia and built on `Rasters.jl` for geospatial data handling. Data is represented as raster data cubes with dimensions $(x,y,t)$, and cleaning is organized as composable functions. Core functions include:

- Missing-data handling: `na_recode`, `na_interp_linear`
- Negative-value handling: `replace_negative`
- Outlier treatment: `outlier_hampel`, `outlier_variance`
- Background-noise filtering: `bgnoise_PSTT2021`
- Cloud-bias correction: `bias_PSTT2021`

These are wrapped into high-level pipelines such as `PSTT2021()`, `PSTT2021_conventional()`, and `clean_complete()`. This design supports both  method-level customization and standardized cleaning pipelines.

Several design choices shaped the package. Primarily, cleaning is exposed as a set of small composable functions rather than a single opaque routine. This enlarges the API surface and requires the user to respect an ordering between steps, but it allows for customization and lets each stage be run, inspected, and switched out independently, which is what makes the package usable for methodological work while still allowing reproducability. Secondly, the package is written in Julia because the core operations are per-pixel time-series computations over large pixel counts. Hampel filters, smoothing-spline fits, linear interpolation are awkward to express as fast vectorised array code and would otherwise require C extensions, if not for Julia's loop performance. Finally, existing best-practices cleaning and cloud-bias-corrected cleaning are kept as separately named and dated pipelines (`PSTT2021_conventional` and `PSTT2021`) so that results remain reproducable as well as directly comparable to the large body of prior work that does not correct for cloud cover.

# Research impact statement

The package has been used as infrastructure for empirical work where cloud cover and data quality strongly affect inference from nighttime lights. Its main impact is methodological consistency: researchers can move from raw files to analysis-ready panels using explicit, shared preprocessing steps.

Because each stage is exposed as a public function, `NighttimeLights.jl` also serves as a platform for methodological development. Users can inspect intermediate outputs, compare alternative cleaning choices, and contribute new preprocessing methods while preserving reproducible workflows.

The cloud-bias correction implemented here was developed and validated in @patnaik2021but, and `NighttimeLights.jl` is the reference implementation of that method. The package has been used to build analysis-ready VIIRS panels for applied economic work, including a study of wartime economic activity in Ukraine [@hande2025shedding] and an analysis of regional economic patterns across Java, Indonesia [@aviliani2026lights]. It also underpins the public India Built and Lit dataset, which distributes cleaned nighttime-lights panels for India [@xkdr2026indiabuiltlit]. Reproducibility is supported concretely: a Mumbai example cube ships with the package and is loaded with `load_example()`, every pipeline stage is a documented public function, the package is registered in the Julia General registry, and the results quoted in this paper were produced with the pinned versions listed under Computational details.

# Computational details

Results referenced in this manuscript were generated with Julia 1.12.6 and `NighttimeLights.jl` 0.9.1. Julia is available at <https://julialang.org/> and the package is available at <https://github.com/xKDR/NighttimeLights.jl>.

Installation from the General registry:

```
] add NighttimeLights
```

# Usage example

The following Julia code shows how to go from raw to cleaned data with `NighttimeLights.jl`. The example uses a rectangle of nighttime lights around Mumbai, which ships with the package and can be loaded with `load_example()`. Two inputs are needed. Both are `Raster` data cubes with dimensions $(x, y, t)$, where $t$ indexes months:

- `mumbai_radiance`: the monthly mean radiance of each pixel, in $nW\ cm^{-2}\ sr^{-1}$.
- `mumbai_n_cloudfree`: the number of cloud-free observations that went into each monthly mean.

The simplest path is a single call:

```julia
mumbai_cleaned = clean_complete(mumbai_radiance, mumbai_n_cloudfree, bgthreshold=4)
```

which is presently identical to:

```julia
mumbai_cleaned = PSTT2021(mumbai_radiance, mumbai_n_cloudfree, bgthreshold=4)
```

Both wrap the sequence of steps below. Each step is a public function, so the sequence can be run one step at a time, inspected, or modified:

```julia
# 1. Missing data: months with no cloud-free observations become `missing`
radiance_na = na_recode(mumbai_radiance, mumbai_n_cloudfree)

# 2. Negative values: recoded as `missing`
radiance_nonneg = replace_negative(radiance_na)

# 3. Background noise: mask out pixels that are dark in the annual image
lit_mask = bgnoise_PSTT2021(radiance_nonneg, mumbai_n_cloudfree, 4)
radiance_lit = apply_mask(radiance_nonneg, lit_mask)

# 4. Cross-sectional outliers: mask out pixels with extreme variance over time
stable_mask = outlier_variance(radiance_lit, lit_mask)
radiance_stable = apply_mask(radiance_lit, stable_mask)

# 5. Time-series outliers: Hampel filter on each pixel's time series
radiance_despiked = long_apply(outlier_hampel, radiance_stable)

# 6. Cloud bias: correct attenuation in months with few cloud-free observations
pixel_mask = lit_mask .* stable_mask
radiance_corrected = bias_PSTT2021(radiance_despiked, mumbai_n_cloudfree, pixel_mask)

# 7. Gaps: linearly interpolate the remaining `missing` values
mumbai_cleaned = long_apply(na_interp_linear, radiance_corrected)
```

Two helpers recur in the sequence. `apply_mask` multiplies every monthly image in a data cube by a 2D mask, so that pixels marked as dropped in the mask are removed from every month. `long_apply` applies a function written for a single pixel's time series to every pixel of a data cube. The steps are:

1. **Missing data.** NOAA reports a radiance of 0 for a pixel-month in which every day was cloudy, which is indistinguishable from a genuinely dark pixel. `na_recode` uses `mumbai_n_cloudfree` to find pixel-months with zero cloud-free observations and recodes their radiance as `missing`.

2. **Negative values.** Radiance cannot be negative. Negative values in the raw data arise from calibration in the presence of airglow [@uprety2019calibration]. `replace_negative` recodes them as `missing`.

3. **Background noise.** Pixels with no lights, such as oceans, forests, and deserts, still show a small positive radiance. `bgnoise_PSTT2021` builds an annual image from the last twelve months of data, weighting each month by its number of cloud-free observations [@guptaEtal2017_analysisViirsDerivedNightlightOverIndia]. Pixels whose annual radiance falls below the threshold (here 4 $nW\ cm^{-2}\ sr^{-1}$) are classified as dark. The result, `lit_mask`, is a 2D mask that is 1 for lit pixels and `missing` for dark ones. Applying it removes the dark pixels from every month.

4. **Cross-sectional outliers.** Fires, gas flares, and similar sources produce pixels whose radiance is far above anything from human settlement, and whose time series is highly variable. `outlier_variance` computes the standard deviation of each pixel's detrended time series and marks the top 0.1% of lit pixels as unstable. The result, `stable_mask`, is applied in the same way as `lit_mask`.

5. **Time-series outliers.** A pixel that is stable overall can still contain isolated spikes. `outlier_hampel` runs a Hampel filter [@pearson2002outliers] over a single time series, with a window of 5 months and a cutoff of 3 standard deviations, and recodes flagged observations as `missing`. `long_apply` runs it over every pixel.

6. **Cloud bias.** Months with few cloud-free observations show attenuated radiance. This is the monsoon dip visible in the raw series of the figure below. For each pixel, `bias_PSTT2021` fits a smoothing spline of detrended radiance on the number of cloud-free observations, and raises observations from cloudy months to the level the spline predicts for clear months [@patnaik2021but]. The combined `pixel_mask` restricts the correction to pixels that survived steps 3 and 4.

7. **Remaining gaps.** `na_interp_linear` fills `missing` values in a time series by linear interpolation between the nearest observed values. Leading and trailing gaps take the nearest observed value. Applied over every pixel, this produces the complete data cube `mumbai_cleaned`.

Steps 1 to 5 and step 7, without the bias correction, are what most applied work already does. They are termed conventional cleaning in @patnaik2021but and are available as `PSTT2021_conventional()`. All three pathways, `clean_complete()`, `PSTT2021()`, and the explicit sequence, apply identical methods to transform the raw inputs into `mumbai_cleaned`.

# An example

![Aggregate radiance of raw and cleaned nighttime lights for Mumbai, January 2014 to January 2018.\label{exampledata}](raw_vs_cleaned.png)

\autoref{exampledata} shows the aggregate radiance of raw and cleaned NL of Mumbai. The notebook that produced this data can be found at <https://github.com/xKDR/NighttimeLights.jl>.
On the $y$ axis, the lines show the aggregate raw and cleaned NL measured in $nW\ cm^{-2}\ sr^{-1}$. The $x$ axis shows time measured in months from January 2014 to January 2018. Note the bias during the monsoon months (e.g. July), which is significantly reduced in the cleaned data.

| Statistic       |    Raw | Cleaned |
| --------------- | -----: | ------: |
| Minimum         |  -0.14 |     0.0 |
| Mean            |    9.1 |     9.1 |
| Median          |    3.2 |     0.0 |
| 99th percentile |   54.0 |    59.0 |
| Maximum         | 4300.0 |   1700.0|

: Effect of cleaning on nighttime lights for Mumbai.

The table shows some summary statistics for raw and cleaned NL for Mumbai. Note the absence of negative values in the datacube. The maximum value after is also lower, as some outlier values have been removed. Half the values in the raw data cube are below 4, these can be attributed to background noise. All these measurements have been zeroed. The increase in the $99^{th}$ percentile value is due to the bias correction procedure.


# AI usage disclosure

No generative AI tools were used in the development of the software package, or the written text. AI assistance was used in formatting tables in the markdown document.

# Acknowledgements

We acknowledge contributions from Anshul Tayal, Siddhant Chauddhary, and Hrishikesh Saikia to the codebase and package design. This work received financial support from the MIT Julia Lab.

# References
