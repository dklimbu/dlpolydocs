IR Spectra Calculation
======================

This tutorial provides step-by-step instructions on IR calculation

It can be helpful to periodically run some simulations to get the spectra every few iterations to see how the spectra is behaving. The fit directory has scripts to setup the sampling and dynamics simulations.

Steps to Calculate Spectra for h-CMD
------------------------------------

1. **Setup Sampling Simulations**

   - Update the variable ``i`` in the ``sample-setup.sh`` script to the iteration you want to calculate the spectra for.  
     Running the script will setup a sample directory in the iteration directory and submit the job.

2. **Generate Dynamics Configurations**

   - Once the sampling is done, update the ``i`` variable in the ``config-setup.sh`` script to the desired iteration and run the script.  
     This will create the dynamics trajectory as well as the ``config`` directory and copy the sampling ``HISTORY`` file into it.  
     Use the ``rpmdConfig`` program to generate the ``CONFIG`` files from the ``HISTORY`` file.

3. **Run Dynamics Trajectories**

   - Update the ``i`` variable in the ``dyn-setup.sh`` script and run it to setup all the dynamics trajectories and run the jobs.

4. **Calculate the Spectra**

   - Once all the trajectories are finished, navigate into the dynamics directory and use the ``correlation`` program to calculate the spectra.

