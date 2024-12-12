'# MWS Version: Version 2024.1 - Oct 16 2023 - ACIS 33.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 16 fmax = 32
'# created = '[VERSION]2024.1|33.0.1|20231016[/VERSION]


'@ use template: Lab3_01.cfg

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
'set the units
With Units
    .SetUnit "Length", "mm"
    .SetUnit "Frequency", "GHz"
    .SetUnit "Voltage", "V"
    .SetUnit "Resistance", "Ohm"
    .SetUnit "Inductance", "nH"
    .SetUnit "Temperature",  "degC"
    .SetUnit "Time", "ns"
    .SetUnit "Current", "A"
    .SetUnit "Conductance", "S"
    .SetUnit "Capacitance", "pF"
End With

ThermalSolver.AmbientTemperature "0"

'----------------------------------------------------------------------------

'set the frequency range
Solver.FrequencyRange "1", "2"

'----------------------------------------------------------------------------

Plot.DrawBox True

With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With

With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With

' optimize mesh settings for planar structures

With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With

With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With

With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With

With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With

' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)

MeshAdaption3D.SetAdaptionStrategy "Energy"

' switch on FD-TET setting for accurate farfields

FDSolver.ExtrudeOpenBC "True"

PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"

With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With

'----------------------------------------------------------------------------

With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With

With Mesh
     .MeshType "PBA"
End With

'set the solver type
ChangeSolverType("HF Time Domain")

'----------------------------------------------------------------------------

'@ define material: Rogers RO4350B (lossy)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Material
     .Reset
     .Name "Rogers RO4350B (lossy)"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .SetMaterialUnit "GHz", "mm"
     .Epsilon "3.66"
     .Mu "1.0"
     .Kappa "0.0"
     .TanD "0.0037"
     .TanDFreq "10.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .KappaM "0.0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstKappa"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "General 1st"
     .DispersiveFittingSchemeMu "General 1st"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Rho "0.0"
     .ThermalType "Normal"
     .ThermalConductivity "0.69"
     .SetActiveMaterial "all"
     .Colour "0.94", "0.82", "0.76"
     .Wireframe "False"
     .Transparency "0"
     .Create
End With

'@ new component: component1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "component1"

'@ define brick: component1:Substrate

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Substrate" 
     .Component "component1" 
     .Material "Rogers RO4350B (lossy)" 
     .Xrange "-W", "W" 
     .Yrange "-L", "L" 
     .Zrange "0", "Sub_thick" 
     .Create
End With

'@ rename component: component1 to: Antenna

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.Rename "component1", "Antenna"

'@ define brick: Antenna:Microstrip

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Microstrip" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-Micro_width/2", "Micro_width/2" 
     .Yrange "L/2", "L/2+G" 
     .Zrange "SUb_thick", "Sub_thick+PEC_thick" 
     .Create
End With

'@ define brick: Antenna:PATCH

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "PATCH" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-W/2", "W/2" 
     .Yrange "-L/2", "L/2" 
     .Zrange "Sub_thick", "Sub_thick+PEC_thick" 
     .Create
End With

'@ define brick: Antenna:Ground

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Ground" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-W", "W" 
     .Yrange "-L", "L" 
     .Zrange "-PEC_thick", "0" 
     .Create
End With

'@ boolean add shapes: Antenna:Microstrip, Antenna:PATCH

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Add "Antenna:Microstrip", "Antenna:PATCH"

'@ pick face

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Pick.PickFaceFromId "Antenna:Microstrip", "11"

'@ define port: 1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-0.1", "0.1"
     .Yrange "3.08", "3.08"
     .Zrange "0.25", "0.262"
     .XrangeAdd "0.25*5.13", "0.25*5.13"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.25", "0.25*5.13"
     .SingleEnded "False"
     .WaveguideMonitor "False"
     .Create 
End With

'@ modify port: 1

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Port 
     .Reset 
     .LoadContentForModify "1" 
     .Label ""
     .Folder ""
     .NumberOfModes "1"
     .AdjustPolarization "False"
     .PolarizationAngle "0.0"
     .ReferencePlaneDistance "0"
     .TextSize "50"
     .TextMaxLimit "0"
     .Coordinates "Picks"
     .Orientation "positive"
     .PortOnBound "False"
     .ClipPickedPortToBound "False"
     .Xrange "-0.1", "0.1"
     .Yrange "3.08", "3.08"
     .Zrange "0.25", "0.262"
     .XrangeAdd "0.25*5.13", "0.25*5.13"
     .YrangeAdd "0.0", "0.0"
     .ZrangeAdd "0.25", "0.25*5.13"
     .SingleEnded "False"
     .Shield "PEC"
     .WaveguideMonitor "False"
     .Modify 
End With

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "6" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "1", "2", "0.02", "1", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "True"
     .AutoNormImpedance "True"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ set PBA version

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Discretizer.PBAVersion "2023101624"

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "0", "24"

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "8" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "1", "2", "0.001", "2", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "1", "2"

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "6" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "1", "2", "0.02", "2", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "1", "10"

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "True"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ define frequency range

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solver.FrequencyRange "16", "32"

'@ set 3d mesh adaptation properties

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With MeshAdaption3D
    .SetType "Time" 
    .SetAdaptionStrategy "Energy" 
    .MinPasses "2" 
    .MaxPasses "6" 
    .SkipPulses "0" 
    .CellIncreaseFactor "0.7" 
    .WeightE "1.0" 
    .WeightB "1.0" 
    .RefineX "True" 
    .RefineY "True" 
    .RefineZ "True" 
    .ClearStopCriteria
    .AddSParameterStopCriterion "True", "1", "2", "0.02", "2", "True" 
    .Add0DResultStopCriterion "", "0.02", "1", "False" 
End With

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "True"
     .AutoNormImpedance "True"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ delete shape: Antenna:Microstrip

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Delete "Antenna:Microstrip"

'@ define brick: Antenna:Patch

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Patch" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-W/2", "W/2" 
     .Yrange "-L/2", "L/2" 
     .Zrange "Sub_thick", "Sub_thick+PEC_thick" 
     .Create
End With

'@ define brick: Antenna:Microstrap

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Microstrap" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-Micro_width/2", "Micro_width/2" 
     .Yrange "L/2", "L/2+g" 
     .Zrange "Sub_thick", "Sub_thick+PEC_thick" 
     .Create
End With

'@ define material colour: Rogers RO4350B (lossy)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Material 
     .Name "Rogers RO4350B (lossy)"
     .Folder ""
     .Colour "0.94", "0.82", "0.76" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .ChangeColour 
End With

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "True"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ define farfield monitor: farfield (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=24.032)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .MonitorValue "24.032" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4.08", "4.08", "-3.08", "3.08", "-0.012", "1.5445" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeInflateWithOffset "False" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .EnableNearfieldCalculation "True" 
     .Create 
End With

'@ delete shape: Antenna:Microstrap

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.Delete "Antenna:Microstrap"

'@ pick mid point

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Pick.PickMidpointFromId "Antenna:Patch", "8"

'@ activate local coordinates

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
WCS.ActivateWCS "local"

'@ align wcs with point

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
WCS.AlignWCSWithSelected "Point"

'@ define brick: Antenna:Microstrap

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Brick
     .Reset 
     .Name "Microstrap" 
     .Component "Antenna" 
     .Material "PEC" 
     .Xrange "-Micro_width/2", "Micro_width/2" 
     .Yrange "0", "G" 
     .Zrange "0", "PEC_thick" 
     .Create
End With

'@ new component: Antenna/Patch&strap

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Component.New "Antenna/Patch&strap"

'@ change component: Antenna:Microstrap to: Antenna/Patch&strap:Microstrap

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "Antenna:Microstrap", "Antenna/Patch&strap"

'@ change component: Antenna:Patch to: Antenna/Patch&strap:Patch

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Solid.ChangeComponent "Antenna:Patch", "Antenna/Patch&strap"

'@ define monitor: e-field (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=24.032)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .MonitorValue "24.032" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4.08", "4.08", "-3.08", "3.08", "-0.012", "1.5445" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ define monitor: h-field (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "h-field (f=24.032)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Hfield" 
     .MonitorValue "24.032" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4.08", "4.08", "-3.08", "3.08", "-0.012", "1.5445" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "6" 
     .Step2 "6" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Directivity" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ delete monitor: farfield (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Delete "farfield (f=24.032)" 
End With

'@ define farfield monitor: farfield (f=24.048)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=24.048)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .MonitorValue "24.048" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4", "4", "-3.08", "3.08", "-0.012", "1.5445" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeInflateWithOffset "False" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .EnableNearfieldCalculation "True" 
     .Create 
End With

'@ delete monitor: h-field (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Delete "h-field (f=24.032)" 
End With

'@ define monitor: h-field (f=24.048)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "h-field (f=24.048)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Hfield" 
     .MonitorValue "24.048" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4", "4", "-3.0800000000000001", "3.0800000000000001", "-0.012", "1.5445" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ delete monitor: e-field (f=24.032)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Delete "e-field (f=24.032)" 
End With

'@ define monitor: e-field (f=24.048)

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=24.048)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .MonitorValue "24.048" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-4", "4", "-3.0800000000000001", "3.0800000000000001", "-0.012", "1.5445" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .SetSubvolumeInflateWithOffset "False" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "6" 
     .Step2 "6" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "-1" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .AspectRatio "Free" 
     .ShowGridlines "True" 
     .InvertAxes "False", "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .IncludeUnitCellSidewalls "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .SetMaxReferenceMode "abs" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1.0" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With

'@ define time domain solver parameters

'[VERSION]2024.1|33.0.1|20231016[/VERSION]
Mesh.SetCreator "High Frequency" 

With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .RunDiscretizerOnly "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

