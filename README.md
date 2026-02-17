# 🧬 SDAnext – Survival Data Analysis in MATLAB 📊

---

## 🌟 Overview

**SDAnext** is a MATLAB-based application for the analysis of **cell survival fraction data** in radiation biology and dose–response studies. It provides an intuitive graphical user interface (**GUI**) designed to support both routine analyses and exploratory model comparisons.

| ⭐ Feature             | 📝 Description                                                |
| ----------------------- | ------------------------------------------------------------- |
| 📂 Data validation     | Automatic checks and preprocessing                            |
| 📈 Model fitting       | Multiple radiobiological survival models                      |
| ⚖️ Weighted fits       | Inverse-variance weighting when SDs are available             |
| 🔍 Model scanning      | Comparison of successfully converged and interpretable models |
| 🧬 Multisession viewer | Overlay and styling of multiple datasets                      |
| 🎯 RBE analysis        | SF-based and dose-based RBE computation                       |

---

## 📚 Citation

If you use **SDAnext** in your research, please cite:

> Magro, G. (2026). *SDAnext (vX.Y) Survival Data Analysis*. GitHub. https://github.com/BeppeMagro/SDAnext  
> Licensed under the Apache License 2.0.

👉 Replace `vX.Y` with the current version number of the software.

---

## 🚀 Installation

### 💻 System Requirements

* **Operating System:**
  * **Windows only** (standalone executable available)
  * 🍎 macOS / 🐧 Linux: *source code only; standalone executable not available*
* 🧮 **MATLAB Version:** R2023a or later (running from source)
* 🔧 **MATLAB Runtime:** R2023a (standalone executable)
* 📦 **Required Toolbox:** Curve Fitting Toolbox

> ⚠️ *At present, SDAnext is distributed as a standalone application **only for Windows** (`.exe`). No macOS or Linux standalone binaries are provided.*

### 📥 Standalone Executable for Windows (No MATLAB Required)

If you do **not** have MATLAB installed:

1.  🛠️ **Install MATLAB Runtime** (required only once):
    -   🌐 [Download MATLAB Runtime](https://www.mathworks.com/products/compiler/mcr/index.html) **R2023a** from MathWorks:
        -   🔑 You'll need **administrator rights** for installation.
2.  📦 **Download SDAnext Executable**
    -   🔹 **Option A – GitHub Releases section (recommended)**
        - Precompiled versions of SDAnext are available under the Releases section on GitHub.
        - Each release corresponds to a specific software version.
        - The Windows executable `SDAnext_vX.Y.exe` is directly visible and downloadable.
        - In this case, simply download the `.exe` file.
    -   🔹 **Option B – GitHub Code page**
        1. Go to the main GitHub repository page.
        2. Click the green **Code** button and select **Download ZIP**.
        3. Extract the ZIP archive to your preferred location.
        4. Navigate to the `build` directory and open the most recent subfolder named `YYYY-MM-DD-<index>` (these names reflect the **date and sequence number** of each build) and find the `.exe` file.

💡 *Tip: Once you've found the executable, you can **copy `SDAnext_vX.Y.exe` anywhere** on your computer (e.g., Desktop, Documents, etc.). You may also delete the rest of the downloaded files if you no longer need them.*

🚀 **Launch the application by double-clicking `SDAnext_vX.Y.exe`.**
> 🚫 *macOS and Linux users cannot currently run SDAnext as a standalone application, as no platform-specific executables are available.*

### 🧩 About MATLAB Runtime

To run the application, **MATLAB Runtime (R2023a)** must be installed **only once** on your system.

- If it's already installed, **you don’t need to install it again**.
- If you re-download a new version of SDAnext compiled with a different MATLAB version in the future, you'll need the **matching version** of the Runtime.

📄 In that case, refer to the specific `readme.txt` file found in the corresponding `build/YYYY-MM-DD-*` folder for updated instructions.

### ⚙ Running from MATLAB (For Developers)

1.  📂 Open MATLAB and navigate to the `SDAnext` folder:
    ```matlab
    cd path_to_SDAnext
    ```
2.  🚀 Launch the app:
    -   🎨 Open `SDAnext.mlapp` in App Designer and **click Run**.
    -   ⌨️ Or execute in the MATLAB command window:
        ```matlab
        app = SDAnext;
        ```

---

## 🔎 Input File Format

Plain text input files must contain:

* **Dose (Gy)**
* **Survival Fraction** (0–1)
* Optional: **Standard Deviation** (used for weighting)

📌 Metadata lines start with `!` and support:

* `Title`
* `DisplayName`
* `Color`

💬 Comment lines starting with `#` are ignored and may appear anywhere.

**Example:**

```
!Title='Radiation Dose Response Data'
!DisplayName='Sample Curve A'
!Color='Blue'
1.0 0.90 0.05
2.0 0.80 0.05
3.0 0.70 0.04
4.0 0.60 0.03
```

➕ If a data point at **dose = 0** and **SF = 1** is missing, it is added automatically.
📐 Data are sorted by ascending dose before fitting.

---

## 💡 Basic Workflow

SDAnext is organized around two main tabs, corresponding to two complementary analysis stages: **Fitter** and **Viewer**.

### 🔬 Fitter Tab – Survival Curve Fitting

The **Fitter** tab is dedicated to loading experimental data, fitting survival models, and inspecting fit quality and parameters.

**Typical workflow:**

1. 📂 **Load experimental data**
   - Load one or more datasets using the **Data Loader** panel (`.txt` or `.mat`). Data are automatically validated and preprocessed.

2. 🧮 **Select a survival model**
   - Choose among the available models:
     * Linear (L)
     * Quadratic (Q)
     * Linear–Quadratic (LQ)
     * Linear–Quadratic–Cubic (LQC)
     * Linear–Quadratic–Linear (LQL)

3. ⚙️ **Configure fit options**
   - Adjust bounds, initial guesses, weighting options, and confidence interval settings as needed.

4. ▶️ **Run the fit**
   - Click **Fit Data** to perform the curve fitting. When experimental standard deviations are provided, weighted least squares are applied automatically.

5. 📊 **Inspect results**

   * View fitted curves overlaid on experimental data
   * Inspect fitted parameters and uncertainties
   * Examine goodness-of-fit metrics (RMSE, adjusted R-square, normalized SSE)

6. 🔍 **Model scanning (optional)**
   - Use the **Scan available models** function to automatically test all supported models and compare only those that successfully converge and yield statistically meaningful results.

7. 🔁 **Bidirectional interpolation (optional)**
   - Use the **Interpolator** tool to compute:
     * Dose → Survival Fraction
     * Survival Fraction → Isoeffective Dose

### 📈 Viewer Tab – Multi-session Analysis and RBE

The **Viewer** tab is designed for comparative analyses across multiple datasets and fitted models, including RBE evaluation.

**Typical workflow:**

1. 📥 **Load a session file**
   - Import one or more previously fitted sessions (`.mat` files) generated in the Fitter tab.
2. 🧬 **Manage multiple datasets**
   - Overlay multiple experimental curves and fitted models in a single plot. Styling options allow customization of colors, markers, and line styles.
3. 🎯 **Select the reference model**
   - Explicitly choose the reference curve using the dedicated drop-down menu. The selected reference defines the baseline for RBE calculations.
4. 🧮 **Compute RBE**
   - Trigger RBE computation using the **Compute RBE** control. Two evaluation modes are supported:
      * **Survival-fraction–based RBE:** RBE at fixed SF values
      * **Dose-based RBE:** RBE at fixed reference doses (e.g. 2 Gy)
5. 💾 **Export results**
   - Export RBE tables and related quantities in a structured text format for downstream statistical or clinical analyses.

---

## 🔬 Scientific Background

SDAnext implements survival models commonly used in radiation biology, based on the linear-quadratic model:

$SF = e^{-\alpha D - \beta D^2}$

where:

$D$ = Radiation dose (Gy)
$SF$ = Survival fraction
$\alpha$, $\beta$ = Model parameters

Other supported models extend this equation with cubic or dose threshold-based corrections.

---

## 🛠️ Troubleshooting

**🔴 Application does not start?**

-   ✔️ Ensure that MATLAB Runtime (R2023a) is installed.
-   ✔️ Try running the application as an administrator.

**🟠 MATLAB Runtime is missing or incorrect version?**

-   ✔️ Uninstall any older versions and reinstall MATLAB Runtime R2023a.
-   ✔️ Check your installation using this command in the terminal:

    ```sh
    matlab -batch "ver"
    ```

## 🗑️ Uninstallation

To uninstall SDAnext, simply delete the installation folder. To remove MATLAB Runtime, use the Control Panel (Windows) or the system’s package manager (macOS/Linux).

## 🤝 Contributing

We welcome contributions! If you'd like to improve the app, feel free to:

-   🐞 Report issues via GitHub Issues.
-   🚀 Submit pull requests for new features or bug fixes.

## 📜 License

SDAnext is released under the Apache-2.0 License. See the `LICENSE` file for details.

## 💰 Funding

This work was funded by the National Plan for NRRP Complementary Investments (PNC) in the call for the funding of research initiatives for technologies and innovative trajectories in the health – project n. PNC0000003 – *AdvaNced Technologies for Human-centrEd Medicine* (project acronym: **ANTHEM** – Cascade Call launched by SPOKE 3 POLIMI: **PRECISION**).

## 📧 Contact

For questions or support, contact: giuseppe.magro@cnao.it
