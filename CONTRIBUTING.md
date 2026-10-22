# Contributing to NighttimeLights.jl

Contributions are welcome. This page covers how to report a problem, ask for
help, and submit changes.

## Reporting issues

Open an [issue](https://github.com/xKDR/NighttimeLights.jl/issues) on GitHub.
For bugs, please include:

- a minimal example that reproduces the problem (the bundled Mumbai example
  from `load_example()` is ideal when it applies);
- the full error message and stack trace;
- the output of `julia --version` and `] status NighttimeLights`.

For feature requests, describe the use case and, if you can, the method or
reference you would like implemented. Opening an issue before starting a large
change lets us discuss the approach first.

## Seeking support

Usage questions are also welcome on the
[issue tracker](https://github.com/xKDR/NighttimeLights.jl/issues). Before
asking, please check the
[documentation](https://xKDR.github.io/NighttimeLights.jl/stable), in
particular the tutorial and the data-cleaning pages. You can also reach the
maintainers at XKDR Forum through <https://xkdr.org>.

## Contributing code or documentation

1. Fork the repository and create a branch from `main`.
2. Make your changes. New functions should have a docstring and a test.
3. Run the test suite from the repository root:

   ```
   julia --project=. -e 'using Pkg; Pkg.test()'
   ```

4. If you changed the documentation, build it locally:

   ```
   julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
   julia --project=docs/ docs/make.jl
   ```

5. Open a pull request against `main`. Describe what the change does and why.
   Continuous integration runs the tests on every pull request.

Small fixes to docstrings or documentation pages follow the same flow and are
always appreciated.

## Code layout

- `src/data_cleaning/` — the cleaning steps (missing-value recoding,
  interpolation, negative values, outliers, background noise, bias correction)
  and the pipelines that compose them in `full_procedures.jl`.
- `src/other/` — supporting utilities (detrending, rank correlation, annular
  rings, centre of mass, weighted means).
- `src/readnl.jl` — reading NOAA VIIRS files into data cubes.
- `test/` — one test file per source file, listed in `test/runtests.jl`.
- `docs/` — Documenter.jl sources.

## Conduct

Be respectful and constructive in issues and pull requests. Reports of
unacceptable behaviour can be sent to the maintainers through
<https://xkdr.org>.

## License

By contributing you agree that your contributions are licensed under the
project's [MIT license](LICENSE).
