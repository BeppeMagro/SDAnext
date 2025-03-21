# 🧬 SDAnext – Survival Data Analysis in MATLAB 📊

## 🌟 Overview

**SDAnext** is a powerful MATLAB application designed for analyzing **survival fraction data** in radiation biology and dose-response studies. It provides an intuitive graphical user interface (**GUI**) to streamline your analysis workflow:

✅ Load and validate experimental data effortlessly.
📈 Fit survival models (L, Q, LQ, LQC, LQL) with precision.
⚙️ Perform robust curve fitting using weighted least squares for enhanced accuracy.
📊 Visualize and compare dose-response curves dynamically.
🎯 Estimate dose for a given survival fraction with ease.

---

## 🚀 Installation

### 💻 System Requirements

-   **Operating System:** Windows / macOS / Linux
-   **MATLAB Version:** **R2023a or later** *(for development use)*
-   **MATLAB Runtime Version:** **R2023a** *(for standalone executable)*
-   **Required Toolbox:** **Curve Fitting Toolbox**

### 📥 Download & Setup

#### **1️⃣ Installing the Standalone Executable (No MATLAB Required)**

If you don't have MATLAB installed, follow these simple steps:

1.  📦 **Download SDAnext Executable** and extract it to your preferred location.
2.  🛠️ **Install MATLAB Runtime** (if not already installed):
    -   🌐 Download MATLAB Runtime **R2023a** from MathWorks:
        👉 [Download MATLAB Runtime](https://www.mathworks.com/products/compiler/mcr/index.html)
    -   💻 Or install it from MATLAB by running:
        ```matlab
        >> mcrinstaller
        ```
    -   🔑 You'll need **administrator rights** for installation.
3.  ▶️ **Run SDAnext:**
    -   **Windows:** Double-click `SDAnext.exe`.
    -   **macOS/Linux:** Open a terminal and run:
        ```sh
        ./SDAnext
        ```

#### **2️⃣ Running from MATLAB (For Developers)**

1.  📂 Open MATLAB and navigate to the `SDAnext` folder:

    ```matlab
    cd path_to_SDAnext
    ```

2.  🚀 Launch the app:

    -   🎨 Open `SDAnext.mlapp` in App Designer and click Run.
    -   ⌨️ Or execute in the MATLAB command window:

        ```matlab
        app = SDAnext;
        ```

## 💡 How to Use

**Step 1: 📂 Load Data**

-   🖱️ Click "Load Data" and select your file.
-   ✅ The app automatically validates and preprocesses the dataset.

**Step 2: 📊 Select Model**

-   🔍 Choose a survival model:
    -   Linear (L)
    -   Quadratic (Q)
    -   Linear-Quadratic (LQ)
    -   Linear-Quadratic-Cubic (LQC)
    -   Linear-Quadratic-Linear (LQL)
-   🔧 Adjust fitting parameters as needed.

### 🔎 File Format Requirements

The input data file should be a plain text file with the following specifications:

- Two required columns:
  - **Dose (Gy)**: numeric, ≥ 0
  - **Survival Fraction**: numeric, between 0 and 1
- An optional third column:
  - **Standard Deviation**: numeric, used for computing weights (if missing, weights are uniform)

**Example:**

    ```sh
    # Sample data
	!Title='Radiation Dose Response Data'
	!Color='Blue'
	!DisplayName='Sample Curve A'
	1.0 0.9 0.05
	2.0 0.8 0.05
	3.0 0.7 0.04
	4.0 0.6 0.03
    ```

- Lines starting with `!` are treated as metadata and support the following fields: `Title`, `Color`, `DisplayName`.
- Lines starting with `#` are treated as comments and ignored, wherever they appear in the file. This means they can also be used to temporarily exclude data rows from analysis.
- Data lines must contain numeric values separated by spaces or tabs.
- If a data point with **dose = 0** and **survival fraction = 1** is not present, it will be automatically added by the app.
- Data is automatically sorted in ascending order of dose before being used.

**Step 3: 📈 Fit the Model**

-   🖱️ Click "Fit Data" to perform curve fitting.
-   👀 View the fitted curve and model parameters instantly.

**Step 4: 🔍 Analyze & Export**

-   📊 Compare multiple models within the plot window.
-   💾 Save fitted parameters and plots for further analysis.

## 🌟 Features

| Feature                     | Description                                                                  |
| :-------------------------- | :--------------------------------------------------------------------------- |
| 📂 Data Import & Validation | Supports structured tabular data (Dose, SF, StdDev).                         |
| 📈 Model Selection          | Supports multiple survival models (L, Q, LQ, LQC, LQL).                      |
| ⚙️ Robust Curve Fitting     | Uses MATLAB's `fit` function with weighted least squares.               |
| 📉 Plotting & Visualization | Multi-session support, log-scale Y-axis, customizable plots.            |
| 🎯 Dose Estimation          | Computes the dose corresponding to a given survival fraction.               |

## 🔬 Scientific Background

SDAnext implements survival models commonly used in radiation biology, based on the linear-quadratic model:

$SF = e^{-\alpha D - \beta D^2}$

where:

$D$ = Radiation dose (Gy)
$SF$ = Survival fraction
$\alpha$, $\beta$ = Model parameters

Other supported models extend this equation with cubic or threshold-based corrections.

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

**🟡 Graphical or performance issues?**

-   ✔️ Update your graphics drivers and ensure your system meets the minimum requirements.

## 🗑️ Uninstallation

To uninstall SDAnext, simply delete the installation folder. To remove MATLAB Runtime, use the Control Panel (Windows) or the system’s package manager (macOS/Linux).

## 🤝 Contributing

We welcome contributions! If you'd like to improve the app, feel free to:

-   🐞 Report issues via GitHub Issues.
-   🚀 Submit pull requests for new features or bug fixes.

## 📜 License

SDAnext is released under the Apache-2.0 License. See the `LICENSE` file for details.


## 📧 Contact

For questions or support, contact: giuseppe.magro@cnao.com
