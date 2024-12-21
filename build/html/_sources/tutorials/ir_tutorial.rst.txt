IR Spectra Calculation
======================

This tutorial provides detailed, step-by-step instructions for calculating IR spectra using **h-CMD** simulations. 

Steps to Calculate Spectra for h-CMD
------------------------------------

1. **Setup Sampling Simulations**

   - Update the variable ``i`` in the ``sample-setup.sh`` script to the specific iteration you want to calculate the spectra for.  
     Running the script will setup a **sample** directory in the iteration directory and submit the job.

2. **Generate Dynamics Configurations**

   - Once the sampling is done, update the ``i`` variable in the ``config-setup.sh`` script to the desired iteration and run the script.  
     This will create the **dynamics** trajectory as well as the **config** directory and copy the sampling ``HISTORY`` file into it.  
     Use the ``config`` program to generate the ``CONFIG`` files from the ``HISTORY`` file.

3. **Run Dynamics Trajectories**

   - Update the ``i`` variable in the ``dyn-setup.sh`` script and run it to setup all the dynamics trajectories and run the jobs.

4. **Calculate the Spectra**

   - Once all the trajectories are finished, navigate into the **dynamics** directory and use the ``correlation`` program to calculate the spectra.

     .. code-block:: console

       $ cd iter<i>/dynamics
     
       $ mpirun -n 1 correlation


   .. tip::
     A typical ``CONTROL`` file for IR calculation:

     .. code-block:: console

       50000 5000
       1
       50
       0.001
       dipole
       1.0
       .t.

       !number of time steps to read in, number of time steps to skip
       !number of molecules (use 1 if total dipole was used in DL_POLY)
       !number of trajectories
       !time (ps) between configurations
       !type of correlation function
       !tau value for Hann window (in ps)
       !bool for trimming beginning of trajectory


