# SIM2.2 — Channel-Length Modulation in the 035 NMOS

## Setup

This simulation uses the `NM` Level 8 BSIM3 model and `nmos_035` symbol from the supplied 035 LTspice library. The source and bulk are grounded. The aspect ratio is held at `W/L = 10` for all five devices.

The target overdrive is `VOV = 0.500 V`. Because the model's effective threshold varies with channel length, each gate voltage was calibrated from the LTspice operating-point `Vth` at `VDS = 1.0 V`; `VGS` was then set to `Vth + VOV`. The calibration is in `SIM2_2_NMOS_VTH.cir`. Each gate voltage stays fixed during the output sweep; VOV is matched at the 1.0 V reference point, while the model may shift Vth slightly as VDS changes.

| L (μm) | W (μm) | Vth at VDS = 1 V (V) | VGS (V) | VOV (V) |
|---:|---:|---:|---:|---:|
| 1 | 10 | 0.536 | 1.036 | 0.500 |
| 2 | 20 | 0.518 | 1.018 | 0.500 |
| 5 | 50 | 0.506 | 1.006 | 0.500 |
| 10 | 100 | 0.502 | 1.002 | 0.500 |
| 20 | 200 | 0.500 | 1.000 | 0.500 |

For each device, LTspice swept `VDS` from 0.6 V to 2.0 V in 10 mV steps. The range is above the 0.5 V target overdrive, so it stays in the saturation region for this comparison.

## Method

In saturation, use the assignment's approximation:

\[
I_D \approx I_{D0}(1+\lambda V_{DS}).
\]

The slope and intercept are estimated from the simulated endpoint currents:

\[
g_{ds}\approx\frac{I_D(2.0\,\mathrm V)-I_D(0.6\,\mathrm V)}{2.0-0.6},\qquad
I_{D0}\approx I_D(0.6\,\mathrm V)-0.6g_{ds},\qquad
\lambda\approx\frac{g_{ds}}{I_{D0}}.
\]

Then calculate output resistance at `VDS = 1.3 V` using the requested formula:

\[
r_o\approx\frac{1}{\lambda I_D(1.3\,\mathrm V)}.
\]

## Results

| L (μm) | W (μm) | ID at 1.3 V (μA) | Slope gds (μS) | λ (V⁻¹) | ro (kΩ) |
|---:|---:|---:|---:|---:|---:|
| 1 | 10 | 158.037 | 3.489 | 0.022876 | 276.611 |
| 2 | 20 | 165.261 | 2.464 | 0.015263 | 396.453 |
| 5 | 50 | 169.485 | 1.729 | 0.010358 | 569.653 |
| 10 | 100 | 170.948 | 1.379 | 0.008162 | 716.706 |
| 20 | 200 | 171.633 | 1.097 | 0.006455 | 902.644 |

## Plots

### Drain current versus drain-source voltage

![035 NMOS output characteristics](SIM2_2_NMOS_ID_vs_VDS.png)

### Channel-length modulation and output resistance versus channel length

![Lambda and output resistance versus channel length](SIM2_2_NMOS_lambda_ro_vs_L.png)

## Discussion

As `L` increases from 1 μm to 20 μm, `λ` decreases from 0.022876 V⁻¹ to 0.006455 V⁻¹, while `ro` increases from 276.6 kΩ to 902.6 kΩ. The output curves also become flatter, showing weaker channel-length modulation for longer devices. This agrees with the expected trend: a longer channel reduces the relative effect of drain voltage on channel length and gives a higher output resistance.

The current at 1.3 V rises modestly from 158.0 μA to 171.6 μA even though `W/L` and the calibrated overdrive are held constant. This is the behavior of the supplied BSIM3 model across these geometries; the ideal long-channel square-law model would predict less variation.

## Files

- `SIM2_2_NMOS.asc` — LTspice schematic and stepped output sweep.
- `SIM2_2_NMOS_VTH.cir` — operating-point threshold calibration at `VDS = 1 V`.
- `SIM2_2_NMOS_ID_VDS.csv` — plotted output-curve data.
- `SIM2_2_NMOS_results.csv` — extracted metrics.
