﻿within ThermofluidStream.Undirected.HeatExchangers;
model DiscretizedCrossFlowHEX "Discretized Heat Exchanger for single- or two-phase working fluid without pressure drop"

  replaceable package MediumA =
      ThermofluidStream.Media.myMedia.Interfaces.PartialMedium                           "Medium model side A"
    annotation (choicesAllMatching=true, Dialog(group = "Medium definitions"));
  replaceable package MediumB =
      ThermofluidStream.Media.myMedia.Interfaces.PartialMedium                           "Medium model side B"
    annotation (choicesAllMatching=true, Dialog(group = "Medium definitions"));

  replaceable model ConductionElementA = Internal.ConductionElementHEX constrainedby
    Internal.PartialConductionElementHEX(
    final A=A/nCells,
    final V=V_Hex/nCells,
    redeclare package Medium = MediumA,
    final enforce_global_energy_conservation=enforce_global_energy_conservation,
    final init=init_A,
    final h_0= h0_A)
    "Heat transfer element model for side A"
      annotation(choicesAllMatching=true, Dialog(group = "Medium definitions"));
  replaceable model ConductionElementB = Internal.ConductionElementHEX constrainedby
    Internal.PartialConductionElementHEX(
    final A=A/nCells,
    final V=V_Hex/nCells,
    redeclare package Medium = MediumB,
    final enforce_global_energy_conservation=enforce_global_energy_conservation,
    final init=init_B,
    final h_0= h0_B)
    "Heat transfer element model for side B"
      annotation(choicesAllMatching=true, Dialog(group = "Medium definitions"));

  parameter Boolean initializeMassFlow=false  "Initialize mass flow at inlets?" annotation(Dialog(tab = "Initialization", group = "Mass flow"));
  parameter SI.MassFlowRate m_flow_0_A = 0 "Initial mass flow for side A"
    annotation(Dialog(tab = "Initialization", group = "Mass flow", enable = initializeMassFlow));
  parameter SI.MassFlowRate m_flow_0_B = 0 "Initial mass flow for side B"
    annotation(Dialog(tab = "Initialization", group = "Mass flow", enable = initializeMassFlow));
  parameter ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement init_A=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h
    "Initialization method for h side A)"
    annotation (Dialog(tab="Initialization", group="Enthalpy"),
      choices(
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h "h0",
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.rear "rear",
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.fore "fore"));
  parameter SI.SpecificEnthalpy h0_A = MediumA.h_default "Initial enthalpy side A"
    annotation(Dialog(tab = "Initialization", group = "Enthalpy", enable=(init_A == ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h)));
  parameter ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement init_B=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h
    "Initialization method for h side B"
    annotation (Dialog(tab="Initialization", group="Enthalpy"),
      choices(
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h "h0",
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.rear "rear",
        choice=ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.fore "fore"));
  parameter SI.SpecificEnthalpy h0_B = MediumB.h_default "Initial enthalpy side B"
    annotation(Dialog(tab = "Initialization", group = "Enthalpy", enable=(init_B == ThermofluidStream.Undirected.Processes.Internal.InitializationMethodsCondElement.h)));
  parameter Integer nCells = 3 "Number of discretization elements";
  parameter Modelica.SIunits.Area A = 10 "Conductive area of heat exchanger"
    annotation(Dialog(group = "Heat transfer parameters"));
  parameter Modelica.SIunits.Volume V_Hex = 0.001 "Volume for heat transfer calculation" annotation(Dialog(group = "Heat transfer parameters"));
  parameter Boolean enforce_global_energy_conservation = false "If true, exact global energy conservation is enforced by feeding back all energy stored locally back in the system"
    annotation(Dialog(tab="Advanced"));
  parameter SI.MassFlowRate m_flow_reg = dropOfCommons.m_flow_reg "Regularization massflow to switch between positive- and negative-massflow model"
    annotation(Dialog(tab="Advanced"));

  //Parameterization of HEX Wall
  parameter Modelica.SIunits.CoefficientOfHeatTransfer k_wall = 100 "Coefficient of heat transfer for wall"
    annotation(Dialog(group = "Heat transfer parameters"));

  parameter Boolean calculate_efficency= false "Enable calculation of efficency";

protected
  parameter Modelica.SIunits.ThermalConductance G = k_wall*A "Wall thermal conductance" annotation(Dialog(group = "Wall parameters"));

public
  ConductionElementA thermalElementA[nCells] annotation (Placement(transformation(extent={{-10,90},{10,70}})));

  ConductionElementB thermalElementB[nCells] annotation (Placement(transformation(extent={{10,-90},{-10,-70}})));

  Modelica.Thermal.HeatTransfer.Components.ThermalConductor thermalConductor[nCells](each G=G/nCells)
    annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={0,0})));
  Interfaces.Rear rearA(redeclare package Medium = MediumA) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-98,80}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,100})));
  Interfaces.Fore foreA(redeclare package Medium = MediumA) annotation (Placement(transformation(extent={{92,70},{112,90}}), iconTransformation(
        extent={{-10,-10},{10,10}},
        rotation=270,
        origin={0,-100})));
  Interfaces.Rear rearB(redeclare package Medium = MediumB) annotation (Placement(transformation(extent={{110,-90},{90,-70}})));
  Interfaces.Fore foreB(redeclare package Medium = MediumB) annotation (Placement(transformation(extent={{-90,-90},{-110,-70}})));

  SI.HeatFlowRate Q_flow_A=sum(thermalElementA.heatPort.Q_flow);
  SI.HeatFlowRate Q_flow_B=sum(thermalElementB.heatPort.Q_flow);
  SI.MassFlowRate m_flow_A=rearA.m_flow;
  SI.MassFlowRate m_flow_B=rearB.m_flow;
  SI.Mass M_A=sum(thermalElementA.M);
  SI.Mass M_B=sum(thermalElementB.M);
  SI.Energy deltaE_system=sum(thermalElementA.deltaE_system) + sum(thermalElementB.deltaE_system);

  ThermofluidStream.HeatExchangers.Internal.DiscretizedHEXSummary summary "Summary record of Quantities";

  Processes.FlowResistance                   flowResistanceA[nCells](
    redeclare package Medium = MediumA,
    each r(each displayUnit="mm") = 0.025,
    each l=1,
    redeclare function pLoss =
        ThermofluidStream.Processes.Internal.FlowResistance.linearQuadraticPressureLoss
        (                                                                                                       each k=50))
    annotation (Placement(transformation(extent={{20,70},{40,90}})));
  Topology.JunctionMN junctionMN(redeclare package Medium = MediumA,
    N=1,
    M=nCells)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}},
        rotation=0,
        origin={-50,80})));
  Topology.JunctionMN junctionMN1(redeclare package Medium = MediumA, N=nCells)
    annotation (Placement(transformation(extent={{56,70},{76,90}})));
protected
  outer DropOfCommons dropOfCommons;
  function efficency =
      ThermofluidStream.HeatExchangers.Internal.calculateEfficency (
    redeclare package MediumA = MediumA,
    redeclare package MediumB = MediumB);


  // no regstep since this is only used as a output
  MediumA.ThermodynamicState stateA_in = if noEvent(rearA.m_flow) > 0 then rearA.state_forwards else foreA.state_rearwards;
  MediumA.ThermodynamicState stateA_out = if noEvent(rearA.m_flow) > 0 then foreA.state_forwards else rearA.state_rearwards;
  MediumB.ThermodynamicState stateB_in = if noEvent(rearB.m_flow) > 0 then rearB.state_forwards else foreB.state_rearwards;
  MediumB.ThermodynamicState stateB_out = if noEvent(rearB.m_flow) > 0 then foreB.state_forwards else rearB.state_rearwards;

initial equation

  if initializeMassFlow then
    rearB.m_flow = m_flow_0_B;
    flowResistanceA.m_flow = m_flow_0_A/nCells*ones(nCells);
  else
    for i in 1:nCells-1 loop
      flowResistanceA[i + 1].m_flow = flowResistanceA[1].m_flow;
    end for;
  end if;

equation
  //Summary record
  summary.Tin_A = MediumA.temperature(stateA_in);
  summary.Tin_B = MediumB.temperature(stateB_in);
  summary.Tout_A = MediumA.temperature(stateA_out);
  summary.Tout_B = MediumB.temperature(stateB_out);
  summary.hin_A = MediumA.specificEnthalpy(stateA_in);
  summary.hin_B = MediumB.specificEnthalpy(stateB_in);
  summary.hout_A = MediumA.specificEnthalpy(stateA_out);
  summary.hout_B = MediumB.specificEnthalpy(stateB_out);
  summary.dT_A = summary.Tout_A - summary.Tin_A;
  summary.dT_B = summary.Tout_B - summary.Tin_B;
  summary.dh_A = summary.hout_A - summary.hin_A;
  summary.dh_B = summary.hout_B - summary.hin_B;

  summary.efficency = if calculate_efficency then efficency(stateA_in, stateB_in, stateA_out, stateB_out, rearA.m_flow, rearB.m_flow, Q_flow_A) else 0;

  summary.Q_flow_A = Q_flow_A;
  summary.Q_flow_B = Q_flow_B;

  //Connecting equations (to interconnect pipes)

  //Fluid Side B
  connect(rearB, thermalElementB[1].rear) annotation (Line(points={{100,-80},{10,-80}}, color={28,108,200}));
  for i in 1:nCells-1 loop
    connect(thermalElementB[i].fore, thermalElementB[i + 1].rear);
  end for;
  connect(thermalElementB[nCells].fore, foreB)  annotation (Line(points={{-10,-80},{-100,-80}}, color={28,108,200}));

  connect(thermalElementB.heatPort, thermalConductor.port_a)
    annotation (Line(points={{4.44089e-16,-70.2},{4.44089e-16,-40},{0,-40},{0,-10}}, color={191,0,0}));
  connect(thermalElementA.heatPort, thermalConductor.port_b)
    annotation (Line(points={{4.44089e-16,70.2},{4.44089e-16,40},{0,40},{0,10}}, color={191,0,0}));

    //Fluid side A
  connect(junctionMN1.fores[1], foreA) annotation (Line(
      points={{76,80},{76,80},{102,80}},
      color={28,108,200},
      thickness=0.5));
  connect(junctionMN.rears[1], rearA) annotation (Line(
      points={{-60,80},{-60,80},{-98,80}},
      color={28,108,200},
      thickness=0.5));
  connect(junctionMN.fores, thermalElementA.rear) annotation (Line(
      points={{-40,80},{-30,80},{-30,80},{-10,80}},
      color={28,108,200},
      thickness=0.5));
  connect(flowResistanceA.rear, thermalElementA.fore) annotation (Line(
      points={{20,80},{10,80}},
      color={28,108,200},
      thickness=0.5));
  connect(flowResistanceA.fore, junctionMN1.rears)
    annotation (Line(points={{40,80},{56,80}},color={28,108,200},thickness=0.5));

  annotation (Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,100}}),
                                                                graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={28,108,200},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          radius=25),
        Polygon(points={{-80,-92},{70,-92},{70,-62},{-80,-62},{-70,-52},{80,-52},{80,-82},{70,-92},{70,-62},{80,-52},{-70,-52},{-80,-62},{-80,-92}},
            lineColor={28,108,200}),
        Line(points={{-40,-52},{-50,-62},{-50,-92}}, color={28,108,200}),
        Line(points={{-10,-52},{-20,-62},{-20,-92}},color={28,108,200}),
        Line(points={{20,-52},{10,-62},{10,-92}}, color={28,108,200}),
        Line(points={{50,-52},{40,-62},{40,-92}}, color={28,108,200}),
        Text(
          extent={{-70,-72},{-58,-84}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="N"),
        Text(
          extent={{52,-72},{64,-84}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="1"),
        Text(
          extent={{20,-72},{32,-84}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="2"),
        Text(
          extent={{-10,-72},{2,-84}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="..."),
        Text(
          extent={{-40,-72},{-28,-84}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="..."),
        Polygon(points={{-80,56},{70,56},{70,86},{-80,86},{-70,96},{80,96},{80,66},{70,56},{70,86},{80,96},{-70,96},{-80,86},{-80,56}},
            lineColor =                                                                                             {28,
              108,200}),
        Line(points={{-40,96},{-50,86},{-50,56}}, color={28,108,200}),
        Line(points={{-10,96},{-20,86},{-20,56}}, color={28,108,200}),
        Line(points={{20,96},{10,86},{10,56}}, color={28,108,200}),
        Line(points={{50,96},{40,86},{40,56}}, color={28,108,200}),
        Text(
          extent={{-72,76},{-60,64}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="N"),
        Text(
          extent={{-42,76},{-30,64}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="..."),
        Text(
          extent={{-10,76},{2,64}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="..."),
        Text(
          extent={{20,76},{32,64}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="2"),
        Text(
          extent={{50,76},{62,64}},
          lineColor={28,108,200},
          pattern=LinePattern.Dash,
          textString="1"),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={-61,36},
          rotation=270),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={1,36},
          rotation=270),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={61,36},
          rotation=270),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={57,-36},
          rotation=90),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={-65,-36},
          rotation=90),
        Text(
          extent={{-8,41},{8,-41}},
          lineColor={188,36,38},
          lineThickness=0.5,
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid,
          textString="«",
          origin={-3,-36},
          rotation=90),
        Polygon(points={{-82,-16},{68,-16},{68,4},{-82,4},{-72,14},{78,14},{78,-6},{68,-16},{68,4},{78,14},{-72,14},{-82,4},{-82,-16}},
            lineColor =                                                                                             {188,
              36,38}),
        Line(points={{-42,14},{-52,4},{-52,-16}}, color={188,36,38}),
        Line(points={{-12,14},{-22,4},{-22,-16}}, color={188,36,38}),
        Line(points={{18,14},{8,4},{8,-16}},   color={188,36,38}),
        Line(points={{48,14},{38,4},{38,-16}}, color={188,36,38})}),
                                                                 Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}})),
    Documentation(info="<html>
<p>The undirected cross-flow discretized heat exchanger uses a number of conduction elements (which is set by the parameter nCells) as discrete control volumes to exchange heat between two fluid streams. </p>
<p>Side A splits the fluid stream into nCells substreams that are parallel. The flow-resistance is chosen to be very small and only ensures numerical stability of the parallel streams. By default, it is a linear-quadratic flow resistance, so the massflows through each of the parallel streams is the same. If exchanged for flow-resistance that depends on media properties (e.g. a laminar-turbulent) the mass-flow on the paths will be different. For side B the elements are serial and numbered 1 to nCells in from rear to fore. The elements&apos; heatports are connected via a thermal conductor that models the wall. The connections are ordered to result in a cross-flow configuration. </p>
<p>The conduction elements are computing a heat transfer coefficient between their heatport and the fluid contained. They are replaceable with a choice between a single-phase and a two-phase version, both can be further parametrized. Although the single-phase version works for two-phase media (not the other way around), using the two-phase one for two-phase media enables to set different heat transfer coefficients depending on the phase (liquid/gaseous/2-phase) state of the medium. </p>
<p>Note that since the model uses conductionElements as discrete control volumes that in turn assume quasi-stationary mass and therefore are part of a fluid stream rather than break it into two (like a full volume would), the same holds for both sides of the heat exchanger; they are part of a fluid stream and don&apos;t break it. The quasi-stationary mass assumption also implies that for (fast) changing masses/densities in any of the conduction elements the heat exchanger will (slightly) violate the conservation of energy.</p>
<p>The parameters A (heat transferring area), k_wall (heat transfer coefficient of the wall between the streams) and the heat transfer coefficients in the conduction elements scale the transferred heat (the middle only if the wall and the latter only of the heat transfer into a fluid is the choke of the heatflow). </p>
<p>The parameter V determines the amount of fluid in the heat exchanger and therefore the dynamic for non-steady states. </p>
<p>The initialization tab allows for a mass-flow initialization for both paths, as well as to determine from which direction the enthalpy in the control volumes should be initialized (fore/rear), or if it should start with a given enthalpy. The other option is to initialize the enthalpy with a given value.</p>
<p>The Advanced tab allows to influence the massflow regularization for near zero massflows and has an option to enforce global conservation of energy. The latter is done by feeding back any energy the conduction elements accumulated over time, basically making it impossible to store energy in their fluid long-term. While this enforces long-term conservation of energy it changes the medium-/short-term dynamics of the system and is therefore disabled by default. </p>
</html>"));
end DiscretizedCrossFlowHEX;
