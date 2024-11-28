h-CMD Tutorial
==============

This tutorial provides step-by-step instructions on using Iterative Boltzmann Inversion (IBI) for **h-CMD** fitting in **DLPOLY Quantum** [#1]_.

Step 1: Setup h-CMD
--------------------
To perform h-CMD simulations, additional keywords are added to the ``CONTROL`` file. This ``CONTROL`` file is used for performing the initial PIMD reference calculations, where the keyword ``pimd`` indicates the integrator to be used.

.. literalinclude:: CONTROL
   :language: bash
   :caption: ``CONTROL``

1.1 h-CMD Specification
^^^^^^^^^^^^^^^^^^^^^^^
The simulation is specified as part of an h-CMD simulation using the ``fqcmd`` keyword. When this keyword is added for systems with multiple molecule types (as defined in the ``FIELD`` file), DL POLY Quantum automatically treats the simulation as h-CMD.  

.. note::
   In **Version 2.1**, the software assumes the final molecule type (typically water) is treated at the f-QCMD level, while other molecule types are treated at the f-CMD level.

1.2 FQCMD Keyword Options in ``CONTROL`` File
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The options following the ``fqcmd`` keyword determine how the h-CMD simulation works:

- ``pot`` **Option**: Specifies the number of non-bonded pair interactions using a correction potential.  
- ``points`` **Option**: Specifies the number of grid points in the ``TABLE`` files.
- ``bnd`` **Option**: Specifies the total number of unique bonds.
- ``rmax`` **Option**: Defines the maximum value for the bond distribution function.
- ``ang`` **Option**: Specifies the total number of unique angles.  
- ``wrt`` **Option**: Defines the number of timesteps between distribution function calculations.

.. note::
  Each non-bonded pair has an associated ``TABLE`` file named ``PAIR_<i>_POT.TABLE``.  
  The first line of the table contains the atom names as defined in the ``FIELD`` file.  
  During PIMD reference simulations, potential and force values in the table are ignored; however, pair names are used to calculate RDFs.
.. note::
   - The maximum value for angle distribution is set to π.  
   - The maximum for RDFs is the non-bonded cutoff value in the ``CONTROL`` file.

1.3 Output Files
^^^^^^^^^^^^^^^^
h-CMD simulations generate three additional output files:

- ``AVERAGE_INTRA.D``: Includes intramolecular bond distributions.
- ``AVERAGE_ANGLE.D``: Includes intramolecular angle distributions.
- ``AVERAGE_RDF.D``: Includes the RDFs for the system.

.. note::
   The number of points in these output files is defined by the ``outpts`` option in the ``CONTROL`` file.


1.4 FQCMD File
^^^^^^^^^^^^^^
An additional input file, the ``FQCMD`` file, is required for h-CMD simulations.  
For the Li-TFSI system, an example is shown here. 

.. literalinclude:: FQCMD
   :language: console
   :caption: ``FQCMD``

.. note::
  - **FQCMD** file includes details about the ``bonds`` and ``angles`` for each molecule type in the same order as in the ``FIELD`` file:
  - ``bonds`` **option** specifies the number of unique bond types for a molecule and their occurrences.  
  - ``angles`` **option** specifies the number of unique angle types and their occurrences.

Step 2: PIMD Reference Simulation
---------------------------------
For h-CMD simulation, at first, a **Reference PIMD Simulation** must be carried out to compute the reference intra- and inter-molecular distribution functions. These distributions serve as the benchmark that the effective potentials will aim to replicate.

.. note::
   It is often advantageous to perform multiple PIMD reference simulations starting from different initial configurations. This approach improves the statistical accuracy of the calculated distribution functions.

2.1 **Prepare the Reference PIMD Simulation:**
   - Set up the input files (``CONFIG``, ``CONTROL``, ``FIELD``, ``FQCMD``, ``PAIR_<i>_POT.TABLE``) of a PIMD simulation for **DLPOLY Quantum**.

2.2 **Run the PIMD Simulation:**
   - Execute the simulation to gather sufficient sampling of the reference system. 
   - Simulation conditions typically include:
     - Canonical ensemble (NVT) with a quantum thermostat.
     - Number of beads (`n_beads`) to achieve convergence in quantum effects.
     - Adequate simulation time to ensure good sampling of the distributions.

2.3 **Calculate Reference Distributions:**
   - ``Average_Intra.d``
   - ``Average_Angle.d``
   - ``Average_RDF.d``

Step 3: Classical Simulations (``iter0``)
-----------------------------------------
To begin the IBI process, an **iteration 0** is needed where the dynamics are performed classically using the base force field potential. This is equivalent to performing h-CMD with the correction potentials set to zero. 

Most of the setup work done for the PIMD reference simulations can be reused here:

- ``FQCMD`` **file**: No changes are required.
- ``PAIR_<i>_POT.TABLE`` **files**: All values of the potential and force must be set to zero so that the dynamics are not altered from the base potential.
- ``CONTROL`` **file**: This file remains very similar to the one used previously, with alter in integrator as:
  
.. code-block:: bash
      
   . 
   integration velocity verlet
   ensemble nvt nhc 0.05 1 3
   .
   .
   .
   fqcmd  pot=15  points=998  outpts=480  bnd=5  ang=8  wrt=100
   .

.. note::
    Changes made in ``CONTROL`` file:
  
    - The integrator is changed to invoke the velocity Verlet algorithm.
    - The NVT ensemble is maintained through a m-NHC thermostat.
    - The simulation length can be shortened since RDFs are calculated using force sampling in classical dynamics.

This step performs classical dynamics without correction, providing a baseline, which serve as the starting point for subsequent iterations in the IBI process.


Step 4: IBI Iteration Workflow
------------------------------
After the **PIMD** reference and **iteration 0** simulations are complete, the IBI process can begin to refine the effective ineraction potentials. Between each IBI iteration, the correction potentials are updated. This update is done using a separate Python script.

A small portion of the script, designed to work on high-performance computing clusters with SLURM schedulers, requires modification to detail the system of interest.
Most of the detail parallels the ``FQCMD`` and ``CONTROL`` files, with some additional information required.
For example, the ``pairtype`` array specifies the non-bonded pairs for which the correction potential is calculated.

.. literalinclude:: IBI_code.py
   :language: python
   :caption: `Snippet of the IBI code detailing the non-bonded pairs and intramolecular details for the Li-TFSI system.`

.. note::

   - ``pairtype``: Holds the list of non-bonded pairs for correction potential calculations. This list should match the TABLE files.

   - ``nbonds``: Specifies the number of unique bonds in each molecule type.

   - ``nangs``: Specifies the number of unique angles in each molecule type.

   - ``bonds`` and ``angles``: Store information about each unique bond and angle type, including occurrences.

.. note::
   To execute the IBI script, two additional files are required:
  
   - ``OLD_FIELD``: The FIELD file from **iteration 0**, renamed to OLD_FIELD. This file contains bond and angle force field parameters.
   - ``PREVIOUS_POTENTIAL.DAT``: Combines the correction potentials for all pairs from the previous iteration. For **iteration 0**, these values will be zero, but the file is still necessary.

.. note::
   Once the IBI script is executed, the following new files are created:

   - ``NEW_FIELD``: Contains updated intramolecular force field parameters.
   - ``NEW_POTENTIAL.DAT``: Includes updated intermolecular correction potentials.
   - ``PAIR_<i>_POT.TABLE`` files: Generated for each pair type, containing new potentials and forces.

The updated files are used to run simulations for the next iteration. Starting with **iteration 1**, the dynamics are now classical dynamics under the correction potentials, mimicking PI-based dynamics. The process is repeated until the distribution functions sufficiently match those of the PIMD reference simulations.

.. note::

   A set of scripts is provided to automate the setup and execution of multiple IBI iterations, designed to work on high performance computing clusters with SLURM schedulers, with the jobs for later iterations requiring the previous ones to finish before running

Here is workflow of for single interation IBI fitting.

Step 4.1: IBI Iteration Setup:
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

Step 4.2: Running Simulations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Execute the ``iter-setup.sh`` script:

   .. code-block:: console
   
      $ bash iter-setup.sh

This will start  50 classical-like dynamics under the correction potentials and generate RDFs for each trajectory. The ``CONTROL`` file looks like:

   .. code-block:: bash
      
      . 
      integration velocity verlet
      ensemble nvt nhc 0.05 1 3
      .
      .
      .
      fqcmd  pot=15  points=998  outpts=480  bnd=5  ang=8  wrt=100
      .

Step 4.3: Averaging RDFs
^^^^^^^^^^^^^^^^^^^^^^^^

1. Navigate to the simulation directory after the completion of simulation where the RDFs are stored:

   .. code-block:: console

     $ cd iter<current_iteration_number>/run

2. Use the **rdfAvg** program (provided in utility folder) to compute the average RDFs from all trajectories:
   
   .. code-block:: console

      $ rdfAvg

   .. note::
      If you change the number of trajecties or RDF points, update the ``avgCONTROL`` file to reflect these changes.

Step 4.4: Updating Potentials
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Return to the iteration directory; Move up one directory to the main iteration forder:

   .. code-block:: console

      $ cd ..

2. Ensure the following required files exist.

   - ``OLD_FIELD`` (*FIELD file from the previous iteration*)
   - ``PREVIOUS_POTENTIAL.DAT`` (*potential corrections from the previous iteration*)

3. Run the IBI Python script to generate updated potentials:

   .. code-block:: console
      
      $ python IBI.py

   The script generates the updated potential corrections:
   
   - ``NEW_FIELD``
   - ``NEW_POTENTIAL.DAT.dat``
   - A series of ``PAIR_<i>_POT>TABLE`` files

Step 4.5: Evaluating Convergence
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
   * - ``OLD_FIELD``
     - Field file from the previous iteration.
   * - ``NEW_FIELD``
     - Updated field file generated by the IBI script.
   * - ``PREVIOUS_POTENTIAL.DAT``
     - Potential corrections from the previous iteration.
   * - ``NEW_POTENTIAL.DAT``
     - Updated potential corrections.
   * - ``PAIR_<i>_POT.TABLE``
     - Individual tables representing updated potentials for specific interactions.


References
----------

.. [#1] London, N.; Limbu, D. K.; Momeni, M. R.; Shakib, F. A. DL_POLY Quantum 2.0: A Modular General-Purpose Software for Advanced Path Integral Simulations. J. Chem. Phys. **2024**,160, 132501
