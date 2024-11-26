h-CMD Tutorial
==============

This tutorial provides step-by-step instructions on using Iterative Boltzmann Inversion (IBI) for **h-CMD** fitting in **DLPOLY Quantum**.

Step 0: Reference PIMD Simulations
----------------------------------

Before starting the Iterative Boltzmann Inversion (IBI) process, a **Reference PIMD Simulation** must be carried out 
to compute the reference intra- and inter-molecular distribution functions. These distributions serve as the benchmark that the effective potentials will aim to replicate.

1. **Prepare the Reference PIMD Simulation:**

   - Set up the input files (CONFIG, CONTROL, FIELD) of a PIMD simulation for **DLPOLY Quantum**.

2. **Run the PIMD Simulation:**

   - Execute the simulation to gather sufficient sampling of the reference system. 
   - Simulation conditions typically include:

     - Canonical ensemble (NVT) with a quantum thermostat.
     - Number of beads (`n_beads`) to achieve convergence in quantum effects.
     - Adequate simulation time to ensure good sampling of the distributions.

3. **Calculate Reference Distributions:**

   - ``Average_Intra.d``
   - ``Average_Angle.d``
   - ``Average_RDF.d``

Step 1: Classical Simulations (``iter0``)
-----------------------------------------

After obtaining the reference distributions, an initial iteration, referred to as **Iteration 0**, (``iter0``) is performed under the following conditions:

- The correction potentials, :math:`\Delta V_{\text{intra}}^{(0)}(r)` and :math:`\Delta V_{\text{inter}}^{(0)}(r)`, are all set to **zero**.
- The system evolves using the classical potential, :math:`(V_{\text{cl}}(r))`.

This step simulates classical dynamics without correction, providing a baseline, which serve as the starting point for subsequent iterations in the IBI process.


Step 2: IBI Iteration Workflow
------------------------------

Iterative Boltzmann Inversion (IBI) is used to refine effective interaction potentials by matching intra- and inter-molecular distribution fuctions.

Step 2.1: IBI Iteration Setup:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Prepare the ``iter-setup.sh`` script to automate iteration setup: \
   Each iteration runs 50 NVT simulations with 50 ps of equilibration and 50 ps of RDF gathering.

2. Edit the simulation parameters in the ``iterCONTROL`` file. Example settings include temperature, time steps, and RDF parameters.

3. Update the ``iteration number`` in the ``iter-setup.sh`` script:
  
   .. code-block:: console
   
      i=<current_iteration_number>

   .. literalinclude:: iter-setup.sh
      :language: bash
      :caption: ``iter-setup.sh``

Step 2.2: Running Simulations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Execute the ``iter-setup.sh`` script:

   .. code-block:: console
   
      $ bash iter-setup.sh

This will start  50 classical-like dynamics under the correction potentials and generate RDFs for each trajectory. The ``CONTROL`` file looks like:

   .. code-block:: bash
   
      fqcmd  pot=15  points=998  outpts=480  bnd=5  ang=8  wrt=100

Step 2.3: Averaging RDFs
^^^^^^^^^^^^^^^^^^^^^^^^

1. Navigate to the simulation directory after the completion of simulation where the RDFs are stored:

   .. code-block:: console

     $ cd iter<current_iteration_number>/run

2. Use the **rdfAvg** program (provided in utility folder) to compute the average RDFs from all trajectories:
   
   .. code-block:: console

      $ rdfAvg

   .. note::
      If you change the number of trajecties or RDF points, update the ``avgCONTROL`` file to reflect these changes.

Step 2.4: Updating Potentials
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Return to the iteration directory; Move up one directory to the main iteration forder:

   .. code-block:: console

      $ cd ..

2. Ensure the following required files exist.

   - ``old_FIELD`` (*FIELD file from the previous iteration*)
   - ``Previous_Potential.dat`` (*potential corrections from the previous iteration*)

3. Run the IBI Python script to generate updated potentials:

   .. code-block:: console
      
      $ python IBI.py

   The script generates the updated potential corrections:
   
   - ``new_FIELD``
   - ``New_Potential.dat``
   - A series of ``*.table`` files

Step 2.5: Evaluating Convergence
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
- Compare the RDFs of the reference and the currect iteration. 
- If the RDFs do not match, repeat the process by starting a new iteration by updating the ``iteration number`` in ``iter-setup.sh`` and rerun the steps above.


Key Files and Their Roles
-------------------------

This table describes the key files used during the IBI process and their roles.

.. list-table::
   :header-rows: 1
   :widths: 20 80

   * - File Name
     - Description
   * - ``iter-setup.sh``
     - Bash script to automate simulation setup and execution for the current iteration.
   * - ``iterCONTROL``
     - Configuration file for controlling simulation parameters.
   * - ``avgCONTROL``
     - Configuration file for averaging RDFs.
   * - ``old_FIELD``
     - Field file from the previous iteration.
   * - ``new_FIELD``
     - Updated field file generated by the IBI script.
   * - ``Previous_Potential.dat``
     - Potential corrections from the previous iteration.
   * - ``New_Potential.dat``
     - Updated potential corrections.
   * - ``*.table``
     - Individual tables representing updated potentials for specific interactions.


