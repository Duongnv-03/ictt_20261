# SIM2.2 — 035 NMOS Channel-Length Modulation

## Setup and selected bias

This simulation uses the `NM` Level 8 BSIM3 model and `nmos_035` symbol from the supplied 035 LTspice library. The source and bulk are grounded. The aspect ratio is held at `W/L = 10` for all five devices.

The assignment requires a constant overdrive but does not prescribe its numerical value or the drain-voltage sweep endpoints. We choose a nominal `VOV = 0.500 V` as a clear, practical bias point. For the supplied model, the threshold at the 1 V reference point is about 0.500–0.536 V across the five lengths, so this target gives `VGS` values near 1.0 V. `VGS` is calibrated separately for each length from the LTspice operating-point `Vth` at `VDS = 1.0 V`, using `VGS = Vth + VOV`; this keeps the nominal overdrive comparable as L changes.

| L (μm) | W (μm) | Vth at VDS = 1 V (V) | VGS (V) | Nominal VOV (V) |
|---:|---:|---:|---:|---:|
| 1 | 10 | 0.536 | 1.036 | 0.500 |
| 2 | 20 | 0.518 | 1.018 | 0.500 |
| 5 | 50 | 0.506 | 1.006 | 0.500 |
| 10 | 100 | 0.502 | 1.002 | 0.500 |
| 20 | 200 | 0.500 | 1.000 | 0.500 |

The full characteristic is swept from `VDS = 0 V` to `2.0 V` in 10 mV steps. This displays the low-`VDS` triode region as well as the saturation region. The upper endpoint of 2.0 V is a selected sweep limit that gives a broad drain-voltage range for observing the output slope.

With the simple long-channel criterion, the saturation boundary is `VDS ≈ VGS − Vth = VOV`, nominally about 0.5 V here. We use the interval from 0.5 V to 2.0 V for the `λ` calculation, starting at the selected nominal boundary. Points below 0.5 V remain in the full-characteristic plot but are excluded from the saturation calculation.

The gate voltages are fixed during each drain sweep. Because the BSIM3 model can shift its effective `Vth` slightly with `VDS`, the 0.500 V overdrive is matched at the 1.0 V reference point and is nominal over the sweep rather than mathematically exact at every point.

## Method

In saturation, use the assignment's approximation:

\[
I_D \approx I_{D0}(1+\lambda V_{DS}).
\]

Estimate the average slope over the selected 0.5–2.0 V interval, using the simulated values at its two endpoints:

\[
g_{ds}\approx\frac{I_D(2.0\,\mathrm V)-I_D(0.5\,\mathrm V)}{2.0-0.5},\qquad
I_{D0}=I_D(0.5\,\mathrm V),\qquad
\lambda\approx\frac{g_{ds}}{I_{D0}}.
\]

The assignment does not specify which saturation-region bias point should be used for `ID` in the `ro` formula. Here we choose `VDS = 1.5 V` because it is a round value inside the 0.5–2.0 V saturation interval. A different saturation-region `VDS` would give a slightly different `ro`, because `ro = 1/(λID)` depends on the bias current.

Then calculate output resistance at the selected `VDS = 1.5 V` using the requested formula:

\[
r_o\approx\frac{1}{\lambda I_D(1.5\,\mathrm V)}.
\]

The sweep starts at 0 V for the plot, but samples below 0.5 V are not used in these saturation-region calculations.

## Results

| L (μm) | W (μm) | ID at 1.5 V (μA) | Slope gds (μS) | λ (V⁻¹) | ro (kΩ) |
|---:|---:|---:|---:|---:|---:|
| 1 | 10 | 158.519 | 4.238 | 0.027670 | 227.985 |
| 2 | 20 | 165.615 | 3.017 | 0.018642 | 323.898 |
| 5 | 50 | 169.750 | 2.130 | 0.012743 | 462.306 |
| 10 | 100 | 171.163 | 1.727 | 0.010215 | 571.923 |
| 20 | 200 | 171.800 | 1.422 | 0.008362 | 696.075 |

## Plots

### Full drain-current characteristic, from 0 V through saturation

The shaded low-voltage region shows the triode portion. The blue shading marks the 0.5–2.0 V interval used to estimate `λ`.

![Full 035 NMOS output characteristics with saturation fit interval marked](../Simulation/SIM2_2_NMOS_ID_vs_VDS.png)

### Channel-length modulation and output resistance versus channel length

![Lambda and output resistance versus channel length](../Simulation/SIM2_2_NMOS_lambda_ro_vs_L.png)

## Discussion

The full `ID`–`VDS` plot shows the nearly linear rise at low `VDS`, followed by the flatter saturation-region curves. Only the latter interval is used to estimate channel-length modulation, as required by the saturation approximation.

As `L` increases from 1 μm to 20 μm, `λ` decreases from 0.027670 V⁻¹ to 0.008362 V⁻¹, while `ro` increases from 228.0 kΩ to 696.1 kΩ. The output curves become flatter for longer devices, showing weaker channel-length modulation. The current at 1.5 V rises modestly from 158.5 μA to 171.8 μA even though `W/L` and nominal overdrive are held constant. This is the behavior of the supplied BSIM3 model across these geometries; the ideal long-channel square-law model would predict less variation.

## Files

- `../Simulation/SIM2_2_NMOS.asc` — LTspice schematic; sweeps the full `VDS` range from 0 to 2.0 V and measures `λ` and `ro` over the saturation interval.
- `../Simulation/SIM2_2_NMOS_VTH.cir` — operating-point threshold calibration at `VDS = 1 V`.
- `../Simulation/SIM2_2_NMOS_ID_VDS.csv` — full 0–2 V output-characteristic data.
- `../Simulation/SIM2_2_NMOS_results.csv` — metrics calculated from the 0.5–2.0 V saturation interval.
