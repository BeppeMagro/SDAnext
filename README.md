# 🧬 SDAnext – Survival Data Analysis in MATLAB 📊

## 🌟 Overview

**SDAnext** is a powerful MATLAB application designed for analyzing **survival fraction data** in radiation biology and dose-response studies. It provides an intuitive graphical user interface (**GUI**) to streamline your analysis workflow:

✅ Load and validate experimental data effortlessly.
📈 Fit survival models (L, Q, LQ, LQC, LQL) with precision.
⚙️ Perform robust curve fitting using weighted least squares for enhanced accuracy.
📊 Visualize and compare dose-response curves dynamically.
🎯 Estimate dose for a given survival fraction with ease.

---

## 📚 Citation

If you use **SDAnext** in your research, please cite:

> Magro, G. (2025). *SDAnext (vX.Y) Survival Data Analysis*. GitHub. https://github.com/BeppeMagro/SDAnext  
> Licensed under the Apache License 2.0.

👉 Replace `vX.Y` with the current version number of the software.

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
    -   **Windows:** Double-click `SDAnext_vX.Y.exe`.
    -   **macOS/Linux:** Open a terminal and run:
        ```sh
        ./SDAnext
        ```
### 📂 Where to Find the Executable (for Non-Technical Users)

> ⚠️ **Important:** After downloading or extracting the SDAnext package, the executable file `SDAnext_vX.Y.exe` is **not located directly in the main folder**.

Follow these steps to locate and run it:

1. 📁 Open the folder named `build`.
2. 📆 Inside `build`, you will find one or more subfolders named like:
    ```
    2025-03-25-1
    2025-03-25-2
    ```
    These names reflect the **date and sequence number** of each build (format: `YYYY-MM-DD-<index>`).
3. 🔍 Open the **most recent** subfolder.
4. ▶️ Locate the file named:
    ```
    SDAnext_vX.Y.exe
    ```
    and double-click it to launch the application.

💡 *Tip: Once you've found the executable, you can **copy `SDAnext_vX.Y.exe` anywhere** on your computer (e.g., Desktop, Documents, etc.). You may also delete the rest of the downloaded files if you no longer need them.*

---

### 🧩 About MATLAB Runtime

To run the application, **MATLAB Runtime (R2023a)** must be installed **only once** on your system.

- If it's already installed, **you don’t need to install it again**.
- If you re-download a new version of SDAnext compiled with a different MATLAB version in the future, you'll need the **matching version** of the Runtime.

📄 In that case, refer to the specific `README.txt` file found in the corresponding `build/YYYY-MM-DD-*` folder for updated instructions.

---

### 📦 Alternative Download via GitHub Releases

You can also download the latest compiled version of the application directly from the **GitHub Releases section**.

📍 On the main page of the GitHub repository, look at the **right-hand sidebar** or go to the **"Releases"** tab. There you will typically find:

- The **latest executable** file (e.g., `SDA_vX.Y.exe`)
- A matching `README.txt` with build-specific instructions
- The release title and version number (e.g., `SDAnext – Stable Release March 2025`)

➡️ **Simply download the `.exe` file from there and run it – no need to navigate the folder structure manually.**

---

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

    # Sample data
	!Title='Radiation Dose Response Data'
	!Color='Blue'
	!DisplayName='Sample Curve A'
	1.0 0.9 0.05
	2.0 0.8 0.05
	3.0 0.7 0.04
	4.0 0.6 0.03

- Lines starting with `!` are treated as metadata and support the following fields: `Title`, `Color`, `DisplayName`.
- Lines starting with `#` are treated as comments and ignored, wherever they appear in the file. This means they can also be used to temporarily exclude data rows from analysis.
- Data lines must contain numeric values separated by spaces or tabs.
- If a data point with **dose = 0** and **survival fraction = 1** is not present, it will be automatically added by the app.
- Data is automatically sorted in ascending order of dose before being used.

**Step 3: 📈 Fit the Model**

-   🖱️ Click "Fit Data" to perform curve fitting.
-   👀 View the fitted curve and model parameters instantly.

**Step 4: 🔍 Analyze & Export**

-   📊 Compare multiple models within the viewer window.
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
