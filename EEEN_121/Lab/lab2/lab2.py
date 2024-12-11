import win32com.client
import pythoncom





# Function to run simulations for various dipole antenna configurations
def run_cst_dipole_simulation(L1_values, a_values, g=2, frequency_range=(1e9, 2e9)):
    # Create a COM object to interact with CST Studio Suite
    cst = win32com.client.Dispatch("CSTStudio.Application")
    # Create a new Microwave Studio project
    project = cst.NewMWS()
    # Insert a new antenna design called "DipoleSimulation"
    project.InsertDesign("Antenna", "DipoleSimulation")

    # Loop over multiple antenna configurations
    for L1, a in zip(L1_values, a_values):
        # Set the units used in the project to millimeters for length and GHz for frequency
        project.Unit().SetUnits("Length", "mm")
        project.Unit().SetFrequencyUnit("GHz")

        # Define a Perfect Electric Conductor (PEC) material
        project.Material().AddMaterial("PEC")
        project.Material().SetMaterialProperty("PEC")

        # Create the geometry of the dipole antenna using two cylinders
        project.Object().NewCylinder("Cylinder1", "Z", -L1, L1, 2 * a, "PEC")
        project.Object().NewCylinder("Cylinder2", "Z", g, g + L1, 2 * a, "PEC")

        # Define the feed port located between the two cylinders
        project.Port().CreateDiscretePort("FeedPort", [0, 0, 0], [0, 0, g], impedance=50)

        # Set the frequency range for the simulation
        project.Solver().SetFrequencyRange(frequency_range[0] / 1e9, frequency_range[1] / 1e9)

        # Add field monitors to observe electric and magnetic fields and far-field patterns
        project.FieldMonitor().AddFieldMonitor("E-Field", "XoY")
        project.FieldMonitor().AddFieldMonitor("H-Field", "XoZ")
        project.FieldMonitor().AddFarfieldMonitor("FarField", fmin)

        # Run the solver to execute the simulation
        project.Solver().Run()

        # Retrieve simulation results
        results = project.Result()
        results.LoadSParameter1D(1)  # Load S11 parameter
        fmin = results.GetMinimumS11Frequency()
        fR = results.GetResistanceFrequency(50)
        fX = results.GetReactanceFrequency(0)
        bw_10dB = results.CalculateBandwidth(-10)
        bw_6dB = results.CalculateBandwidth(-6)

        # Print the results for this configuration
        print(f"L1={L1}mm, a={a}mm:")
        print(f"fmin (|S11| Minimum Frequency): {fmin} GHz")
        print(f"fR (Resistance 50 Ohms Frequency): {fR} GHz")
        print(f"fX (Reactance 0 Ohms Frequency): {fX} GHz")
        print(f"-10 dB Bandwidth: {bw_10dB} GHz")
        print(f"-6 dB Bandwidth: {bw_6dB} GHz")
        print("-------------------------------")

        # Generate a PowerPoint report for each configuration
        project.Report().GeneratePPT(f"SimulationResults_L1_{L1}_a_{a}.ppt")


# Main block to define parameters and run the function
if __name__ == "__main__":
    # Values for L1 and a
    L1_values = [50, 50, 50]  # mm
    a_values = [1, 5, 10]  # mm

    # Execute the simulation function
    run_cst_dipole_simulation(L1_values, a_values)
