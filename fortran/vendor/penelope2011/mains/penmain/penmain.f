      INCLUDE 'penelope.f'  ! Files included to simplify compilation.
      INCLUDE 'rita.f'
      INCLUDE 'pengeom.f'
      INCLUDE 'penvared.f'
      INCLUDE 'timer.f'

C  Common blocks are defined in the included file 'pmcomms.f'.

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                      C
C         PPPPP   EEEEEE  N    N  M    M    AA    IIII  N    N         C
C         P    P  E       NN   N  MM  MM   A  A    II   NN   N         C
C         P    P  E       N N  N  M MM M  A    A   II   N N  N         C
C         PPPPP   EEEE    N  N N  M    M  AAAAAA   II   N  N N         C
C         P       E       N   NN  M    M  A    A   II   N   NN         C
C         P       EEEEEE  N    N  M    M  A    A  IIII  N    N         C
C                                                                      C
C                                                   (version 2011).    C
C                                                                      C
C  This program performs Monte Carlo simulation of electron-photon     C
C  showers in material structures described with the constructive      C
C  quadric geometry package 'PENGEOM.F'.                               C
C                                                                      C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                      C
C  PENELOPE/PENGEOM (version 2011)                                     C
C  Copyright (c) 2001-2011                                             C
C  Universitat de Barcelona                                            C
C                                                                      C
C  Permission to use, copy, modify, distribute and sell this software  C
C  and its documentation for any purpose is hereby granted without     C
C  fee, provided that the above copyright notice appears in all        C
C  copies and that both that copyright notice and this permission      C
C  notice appear in all supporting documentation. The Universitat de   C
C  Barcelona makes no representations about the suitability of this    C
C  software for any purpose. It is provided 'as is' without express    C
C  or implied warranty.                                                C
C                                                                      C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  In the default mode, the program assumes that primary particles of a
C  given kind, KPARP, are emitted from a point or an extended source,
C  either with fixed energy SE0 or with a specified (histogram-like)
C  energy spectrum. The initial direction of the primary particles is
C  sampled uniformly within a circle of the unit sphere (conical beam),
C  or within a 'rectangular' window (pyramidal beam). Alternatively, the
C  program can read the initial state variables of 'primary' particles
C  from a pre-calculated phase-space file. This option may be used to
C  split the simulation of complex problems into several consecutive
C  stages. The program also admits radiation sources defined by the
C  user, although this requires some editing work.
C
C  >>>>>>>> NOTE: All energies and lengths are given in eV and cm,
C                 respectively.
C
C
C  ************  Structure of the input data file.
C
C  Each line in the input data file consists of a 6-character keyword
C  (columns 1-6) followed either by numerical data (in free format) or
C  by a character string, which start at the 8th column. Keywords are
C  explicitly used/verified by the program (which is case sensitive!).
C  Notice also that the order of the data lines is important. The
C  keyword '______' (6 blanks) indicates comment lines, these can be
C  placed anywhere in the input file. The program ignores any text
C  following the first blank after the last numerical datum, or after
C  the character string, in each line (thus, in the table given below,
C  the comments in square brackets are ignored by the program). Lines
C  with some keywords (e.g., 'SPECTR', 'IPSFN') can appear an arbitrary
C  number of times, limited only by the allocated amount of memory.
C
C  The program assigns default values to many input variables; lines
C  that declare default values may be eliminated from the input file.
C
C
C  The structure of the input file is the following,
C
C  ....+....1....+....2....+....3....+....4....+....5....+....6....+....
C  TITLE  Title of the job, up to 65 characters.
C         . (the dot prevents editors from removing trailing blanks)
C         >>>>>>>> Source definition.
C  SKPAR  KPARP    [Primary particles: 1=electron, 2=photon, 3=positron]
C         KPARP=0 activates a user-defined SOURCE model.
C  SENERG SE0              [Initial energy (monoenergetic sources only)]
C  SPECTR Ei,Pi                 [E bin: lower-end and total probability]
C  SGPOL  SP1,SP2,SP3          [Stokes parameters for polarised photons]
C  SPOSIT SX0,SY0,SZ0                        [Coordinates of the source]
C  SBOX   SSX,SSY,SSZ                            [Source box dimensions]
C  SBODY  KB                [Active source body; one line for each body]
C  SCONE  THETA,PHI,ALPHA                  [Conical beam; angles in deg]
C  SPYRAM THETAL,THETAU,PHIL,PHIU      [Rectangular beam; angles in deg]
C         .
C         >>>>>>>> Input phase-space file (psf).
C  IPSFN  psf-filename.ext         [Input psf name, up to 20 characters]
C  IPSPLI NSPLIT                                      [Splitting number]
C  WGTWIN WGMIN,WGMAX         [Weight window, RR & spl of psf particles]
C  EPMAX  EPMAX                 [Maximum energy of particles in the psf]
C         .
C         >>>>>>>> Material data and simulation parameters.
C                  Up to MAXMAT materials; 2 lines for each material.
C  MFNAME mat-filename.ext               [Material file, up to 20 chars]
C  MSIMPA EABS(1:3),C1,C2,WCC,WCR              [EABS(1:3),C1,C2,WCC,WCR]
C         .
C         >>>>>>>> Geometry and local simulation parameters.
C  GEOMFN geo-filename.ext               [Geometry file, up to 20 chars]
C  DSMAX  KB,DSMAX(KB)              [KB, maximum step length in body KB]
C  EABSB  KB,EABSB(1:3,KB)   [KB, local absorption energies, EABSB(1:3)]
C         .
C         >>>>>>>> Interaction forcing.
C  IFORCE KB,KPAR,ICOL,FORCER,WLOW,WHIG  [KB,KPAR,ICOL,FORCER,WLOW,WHIG]
C         .
C         >>>>>>>> Emerging particles. Energy and angular distributions.
C  NBE    EL,EU,NBE                      [Energy window and no. of bins]
C  NBANGL NBTH,NBPH          [Nos. of bins for the angles THETA and PHI]
C         .
C         >>>>>>>> Impact detectors (up to 25 different detectors).
C         IPSF=0; no psf is created.
C         IPSF=1; a psf is created (for only one detector).
C         IDCUT=0; tracking is discontinued at the detector entrance.
C         IDCUT=1; the detector does not affect the tracking.
C         IDCUT=2; the detector does not affect tracking, the energy
C                  distribution of particle fluence (averaged over the
C                  volume of the detector) is calculated.
C  IMPDET EL,EU,NBE,IPSF,IDCUT      [E-window, no. of bins, IPSF, IDCUT]
C  IDSPC  spc-impdet-##.dat               [Spectrum file name, 20 chars]
C  IDPSF  psf-impdet-##.dat            [Phase-space file name, 20 chars]
C  IDFLNC fln-impdet-##.dat       [Fluence spectrum file name, 20 chars]
C  IDBODY KB                       [Active body; one line for each body]
C  IDKPAR KPAR               [Kind of detected particles, one line each]
C         .
C         >>>>>>>> Energy-deposition detectors (up to 25).
C  ENDETC EL,EU,NBE                   [Energy window and number of bins]
C  EDSPC  spc-enddet-##.dat        [Output spectrum file name, 20 chars]
C  EDBODY KB                       [Active body; one line for each body]
C         .
C         >>>>>>>> Dose distribution.
C  GRIDX  XL,XU                 [X coordinates of the dose box vertices]
C  GRIDY  YL,YU                 [Y coordinates of the dose box vertices]
C  GRIDZ  ZL,ZU                 [Z coordinates of the dose box vertices]
C  GRIDBN NDBX,NDBY,NDBZ                               [Numbers of bins]
C         .
C         >>>>>>>> Job properties.
C  RESUME dump1.dmp               [Resume from this dump file, 20 chars]
C  DUMPTO dump2.dmp                  [Generate this dump file, 20 chars]
C  DUMPP  DUMPP                                 [Dumping period, in sec]
C         .
C  RSEED  ISEED1,ISEED2           [Seeds of the random-number generator]
C  NSIMSH DSHN                     [Desired number of simulated showers]
C  TIME   TIMEA                       [Allotted simulation time, in sec]
C         .
C  END                                  [Ends the reading of input data]
C  ....+....1....+....2....+....3....+....4....+....5....+....6....+....
C
C
C  The following listing describes the function of each of the keywords,
C  the accompanying data and their default values. For clarity, blanks
C  in keywords are indicated as '_'.
C
C  TITLE_ : Title of the job (up to 65 characters).
C             DEFAULT: none (the input file must start with this line)
C
C           The TITLE string is used to mark dump files. To prevent the
C           improper use of wrong resuming files, change the title each
C           time you modify basic parameters of your problem. The code
C           will then be able to identify the inconsistency and to print
C           an error message before stopping.
C
C  >>>>>>>> Source definition.
C
C  SKPAR_ : Kind of primary particle KPARP (1=electrons, 2=photons or
C           3=positrons).
C             DEFAULT: KPARP=1
C           If KPARP=0, the initial states of primary particles are
C           set by subroutine SOURCE, to be provided by the user. An
C           example of that subroutine, corresponding to a 60-Co source
C           (two gamma rays in each nuclear deexcitation), is included
C           at the end of the present source file.
C
C  SENERG : For a monoenergetic source, initial energy SE0 of primary
C           particles.
C             DEFAULT: SE0=1.0E6
C
C  SPECTR : For a source with continuous (stepwise constant) spectrum,
C           each 'SPECTR' line gives the lower end-point of an energy
C           bin of the source spectrum (Ei) and the associated relative
C           probability (Pi), integrated over the bin. Up to NSEM=1000
C           lines, in arbitrary order. The upper end of the spectrum is
C           defined by entering a line with Ei equal to the upper energy
C           end point and with a negative Pi value.
C             DEFAULT: none
C
C  SGPOL_ : This line activates the simulation of polarisation effects
C           in the scattering of photons (electrons and positrons are
C           assumed to be unpolarised). SP1, SP2, SP3 are the Stokes
C           parameters of primary photons, which define the degrees of
C           linear polarisation at 45 deg azimuth, of circular
C           polarisation, and of linear polarisation at zero azimuth,
C           respectively. It is assumed that secondary photons are
C           emitted with null polarisation (SP1=SP2=SP3=0).
C             DEFAULT: none
C
C  SPOSIT : Coordinates of the source centre.
C             DEFAULT: SX0=SY0=0.0, SZ0=0.0D0
C
C  SBOX__ : Extended source box. The source has uniform activity within
C           the volume of a right prism centred at the point (SX0,SY0,
C           SZ0) and whose sides have lengths SSX, SSY and SSZ.
C             DEFAULT: SSX=SSY=SSZ=0.0
C
C  In the case of a extended source, the active volume can be restricted
C  to that of a body or a set of bodies, which must be defined as parts
C  of the geometry. The activity of the source is assumed to be uniform
C  within the volume of the intersection of the active bodies and the
C  source box. Note that the initial coordinates of primary particles
C  are sampled by the rejection method; the sampling efficiency is equal
C  to the fraction of the source box volume that is occupied by active
C  bodies.
C
C  To define each active source body, add the following line:
C
C  SBODY_ : Active source body. One line for each body.
C             DEFAULT: None
C           The program stops if the source box has not been defined
C           previously
C
C  The initial direction of primary particles is sampled unifomrly
C  within a circle on the unit sphere (conical beam), or within a
C  'rectangular' window (pyramidal beam).
C
C  SCONE_ : Conical source beam. Polar and azimuthal angles of the
C           beam axis direction, THETA and PHI, and angular aperture,
C           ALPHA, in deg.
C             DEFAULTS: THETA=0.0, PHI=0.0, ALPHA=0.0
C
C           The case ALPHA=0 defines a monodirectional source, and ALPHA
C           =180 deg corresponds to an isotropic source.
C
C  SPYRAM : Pyramidal source beam. Limiting polar and azimuthal angles
C           of the source beam window, (THETAL,THETAU)x(PHIL,PHIU), in
C           deg.
C             DEFAULTS: THETAL=0.0, THETAU=0.0, PHIL=0.0, PHIU=0.0
C
C           The case THETAL=THETAU, PHIL=PHIU defines a monodirectional
C           source. To define an isotropic source, set THETAL=0, THETAU=
C           180, PHIL=0 and PHIU=360.
C
C           --> Notice that the default source is a pencil beam that
C           moves upwards along the Z-axis.
C
C  >>>>>>>> Input phase-space file.
C
C  The initial state variables of primary particles can be read directly
C  from a set of pre-calculated phase-space files (psf). When this
C  option is active, previous definitions about the source are ignored.
C  Photons from the psf's are assumed to be unpolarized.
C
C  IPSFN_ : Name of an input psf (up to 20 characters).
C             DEFAULT: none
C           Up to 100 psf's may be declared. They are read sequentially.
C
C  The input psf is in ASCII format. Each line defines the initial state
C  of a particle; it contains the following quantities in free format
C  (and in the order they are listed here):
C    -- KPAR, type of particle (1, electron; 2, photon; 3, positron).
C    -- E, energy.
C    -- X,Y,Z, position coordinates.
C    -- U,V,W, direction cosines.
C    -- WGHT, weight.
C    -- ILB(1),ILB(2),ILB(3),ILB(4), a set of indices that provide
C           information on how the particle was generated (see the file
C           'manual.txt').
C    -- NSHI, incremental shower number (difference between the shower
C           numbers of the present particle and the one preceding it
C           in the psf).
C  Phase-space files can be generated by running PENMAIN using an impact
C  detector with the flag IPSF=1 (see below).
C
C  Because of the limited size of the psf's, the results of analogue
C  simulations tend to be 'too noisy'. This can be partially corrected
C  by splitting the particles from the psf.
C
C  IPSPLI : Splitting number. Each particle in the psf's will be split
C           into NSPLIT equivalent particles, with weights equal to
C           WGHT/NSPLIT.
C             DEFAULT: NSPLIT=1 (no splitting)
C
C  --> WARNING: Notice that there is a 'latent' uncertainty in the psf,
C  which sets a limit to the accuracy that can be attained by using
C  large splitting numbers.
C
C  WGTWIN : Weight window, (WGMIN,WGMAX). Particles in the phase-space
C           file that have initial weights WGHT less than WGMIN will be
C           subjected to Russian roulette, and those with WGHT larger
C           than WGMAX will be split. Note that the weight window has
C           preference over the splitting option, i.e., a particle will
C           be split into NSPLIT or less particles only if the latter
C           have weights larger than WGMIN.
C             DEFAULTS: WGMIN=1.0E-35, WGMAX=1.0E35  (no action)
C
C  EPMAX_ : Maximum energy (in eV) of particles in the psf's.
C           EPMAX is the upper limit of the energy interval covered by
C           the simulation lookup tables. To minimise interpolation
C           errors, EPMAX should not be much larger than the maximum
C           energy actually occurring during the simulation.
C
C           When the initial state variables of particles are read from
C           a psf, this parameter is required to initialise PENELOPE and
C           is critical; the code crashes if it finds a particle that
C           has energy larger than EPMAX.
C             DEFAULT: EPMAX=1.0E9 (interpolation is not optimal)
C
C  >>>>>>>> Material data and simulation parameters.
C
C  Each material is defined by introducing the following _two_ lines;
C
C  MFNAME : Name of a PENELOPE input material data file (up to 20
C           characters). This file must be generated in advance by
C           running the program MATERIAL.
C             DEFAULT: none
C
C  MSIMPA : Set of simulation parameters for this material; absorption
C           energies, EABS(1:3,M), elastic scattering parameters, C1(M)
C           and C2(M), and cutoff energy losses for inelastic collisions
C           and bremsstrahlung emission, WCC(M) and WCR(M).
C             DEFAULTS: EABS(1,M)=EABS(3,M)=0.01*EPMAX,
C                       EABS(2,M)=0.001*EPMAX
C                       C1(M)=C2(M)=0.1, WCC=EABS(1,M), WCR=EABS(2,M)
C             EPMAX is the upper limit of the energy interval covered
C             by the simulation lookup tables.
C
C  Note that we must declare a separate material data file name and a
C  set of simulation parameters for each material. The label (material
C  number) asigned by PENELOPE to each material is determined by the
C  ordering of the material data files in the PENMAIN input file. That
C  is, the first, second, ... materials are assigned the labels 1, 2,
C  ... These labels are also used in the geometry definition file.
C
C  The original programs in the distribution package allow up to 10
C  materials. This number can be increased by changing the value of the
C  parameter MAXMAT in the original source files.
C
C  >>>>>>>> Geometry and local simulation parameters.
C
C  GEOMFN : PENGEOM geometry definition file name (a string of up to
C           20 characters).
C             DEFAULT: none.
C
C           --> The geometry definition file can be debugged/visualised
C           with the viewers GVIEW2D and GVIEW3D (operable only under
C           Windows).
C
C  DSMAX_ : Maximum step length DSMAX(KB) of electrons and positrons in
C           body KB. This parameter is important only for thin bodies;
C           it should be given a value of the order of one tenth of the
C           body thickness or less.
C             DEFAULT: DSMAX=1.0E20 (no step length control)
C
C  EABSB_ : Local absorption energies EABSB(KPAR,KB) of particles of
C           type KPAR in body KB. These values must be larger than
C           EABS(KPAR,M), where M is the material of body KB. When the
C           particle is moving within body KB, the absorption energy
C           EABS(KPAR,M) is temporarily set equal to EABSB(KPAR,KB).
C           Thus, the simulation of the particle history is discontinued
C           when the energy becomes less than EABSB(KPAR,KB). This
C           feature can be used, e.g., to reduce the simulation work in
C           regions of lesser interest.
C             DEFAULTS: EABSB(KPAR,KB)=EABS(KPAR,M)  (no action)
C
C  >>>>>>>> Interaction forcing.
C
C  IFORCE : Activates forcing of interactions of type ICOL of particles
C           KPAR in body KB. FORCER is the forcing factor, which must
C           be larger than unity. WLOW and WHIG are the lower and upper
C           limits of the weight window where interaction forcing is
C           applied.
C             DEFAULT: no interaction forcing
C
C           If the mean free path for real interactions of type ICOL is
C           MFP, the program will simulate interactions of this type
C           (real or forced) with an effective mean free path equal to
C           MFP/FORCER.
C
C           TRICK: a negative input value of FORCER, -FN, is  assumed to
C           mean that each particle should interact, on average and
C           approximately, +FN times in a path length equal to the range
C           of that kind of particle with E=EPMAX. This is very useful
C           to generate x-ray spectra from bulk samples.
C
C  The real effect of interaction forcing on the efficiency is not easy
C  to predict. Please, do tentative runs with different FORCER values
C  and check the efficiency gain (or loss!).
C
C  >>>>>>>> Energy and angular distributions of emerging particles.
C
C  NBE___ : Limits EL and EU of the interval where energy distributions
C           of emerging particles are tallied. Number of energy bins
C           (.LE. 1000).
C             DEFAULT: EL=0.0, EU=EPMAX, NBE=500
C
C  NBANGL : Numbers of bins for the polar angle THETA and the azimuthal
C           angle PHI, respectively, NBTH and NBPH (.LE. 180)
C             DEFAULT: NBTH=90, NBPH=1 (azimuthal average)
C
C           NOTE: In the output files, the terms 'upbound' and
C           'downbound' are used to denote particles that leave the
C           material system moving upwards (W>0) and downwards (W<0),
C           respectively.
C
C  >>>>>>>> Impact detectors.
C
C  Each impact detector consists of a set of active bodies, which must
C  have been defined as parts of the geometry. The output spectrum is
C  the energy distribution of particles that entered any of the active
C  bodies coming from a body that is not active (i.e. that is not part
C  of the detector). Notice that a detected particle can re-enter the
C  detector volume and, consequently, be 'counted' several times (except
C  when the flag IDCUT is set equal to 0, see below).
C
C  Active bodies cannot be void, because the geometry routines would not
C  stop particles at their limiting surfaces. In case you need to define
C  detectors outside the material system, fill them with an arbitrary
C  material of very small density to avoid perturbing the transport
C  process.
C
C  To define each impact detector, insert the following block of lines;
C
C  IMPDET : Starts the definition of a new detector. Up to 25 different
C           detectors can be considered.
C           EL and EU are the lower and upper limits of the energy
C             window covered by the impact detector.
C           NBE is the number of bins in the output energy spectrum of
C             the detector (.LE. 1000). If NBE is positive, energy bins
C             have uniform width, DE=(EU-EL)/NBE. When NBE is negative,
C             the bin width increases geometrically with the energy,
C             i.e., the energy bins have uniform width in a logarithmic
C             scale.
C
C           The integer flag IPSF serves to activate the creation of a
C           phase-space file (psf), which contains the state variables
C           of all particles that enter the detector. Use this option
C           with care, because psf's may grow very fast.
C           IPSF=0; no psf is created.
C           IPSF=1; the psf is created. Only one PSF can be created in
C             each simulation run.
C
C           The integer flag IDCUT allows discontinuing the tracking of
C           particles that enter the detector.
C           IDCUT=0; the simulation of a particle is discontinued when
C             it enters the detector (useful to stop the simulation of
C             particles recorded in a psf).
C           IDCUT=1; the presence of the detector does not affect the
C             tracking of particles.
C           IDCUT=2; the presence of the detector does not affect the
C             tracking of particles. The distribution of particle
C             fluence with respect to energy (integrated over the volume
C             of the detector) is tallied. The calculated distribution
C             has dimensions of length/energy.
C
C             DEFAULTS: None
C
C  IDPSF_ : Name of the output phase-space file (up to 20 characters).
C             DEFAULT: 'psf-impdet-##.dat'
C
C  IDSPC_ : Name of the output energy spectrum file (20 characters).
C             DEFAULT: 'spc-impdet-##.dat'
C
C  IDFLNC : Name of the output file with the energy distribution of
C           particle fluence (20 characters). This file is generated
C           only when IDCUT=2.
C             DEFAULT: 'fln-impdet-##.dat'
C
C  IDBODY : Active body of the detector. One line for each active body.
C             DEFAULT: None
C           --> Notice that a body cannot be part of more than one
C           impact detector.
C
C  IDKPAR : Kind of particle that is detected (1=electrons, 2=photons or
C           3=positrons). One line for each kind.
C             DEFAULT: All particles are detected
C
C  >>>>>>>> Energy-deposition detectors.
C
C  Each energy-deposition detector consists of a set of active bodies,
C  which must have been defined as parts of the geometry. The output
C  spectrum is the distribution of absorbed energy (per primary shower)
C  in the active bodies.
C
C           *** WARNING: The energy-deposition spectrum may be strongly
C           biased when interaction forcing is applied within the
C           detector bodies.
C
C  To define each energy-deposition detector insert the following block
C  of lines;
C
C  ENDETC : Starts the definition of a new energy-deposition detector.
C           Up to 25 different detectors can be considered.
C           EL and EU are the lower and upper limits of the energy
C             window covered by the detector.
C           NBE is the number of bins in the output energy spectrum of
C             the detector (.LE. 1000). If NBE is positive, energy bins
C             have uniform width, DE=(EU-EL)/NBE. When NBE is negative,
C             the bin width increases geometrically with the energy,
C             i.e., the energy bins have uniform width in a logarithmic
C             scale.
C
C  EDSPC_ : Name of the output spectrum file (up to 20 characters).
C             DEFAULT: 'spc-enddet-##.dat'
C
C  EDBODY : Active body KB of the detector. One line for each active
C           body.
C             DEFAULT: None
C           --> Notice that a body cannot be part of more than one
C           energy-deposition detector.
C
C  >>>>>>>> Dose map.
C
C  Optionally, the program can calculate the dose distribution inside a
C  parallelepiped (dose box) whose edges are parallel to the axes of the
C  laboratory frame. The dose box is defined by giving the coordinates
C  of its vertices. The dose is tallied using a uniform orthogonal grid
C  with NDBX, NDBY and NDBZ bins (= voxels) along the directions of
C  the respective coordinate axes. These numbers should be odd, to make
C  sure that the 'central' axes (i.e., lines that join the centres of
C  oposite faces of the box) go through the centres of a row of voxels.
C
C  GRIDX_ : X-coordinates of the vertices of the dose box.
C             DEFAULT: None
C  GRIDY_ : Y-coordinates of the vertices of the dose box.
C             DEFAULT: None
C  GRIDZ_ : Z-coordinates of the vertices of the dose box.
C             DEFAULT: None
C  GRIDBN : Numbers of bins NDBX, NDBY, and NDBZ in the X, Y and Z
C             directions, respectively. These values shold be odd and
C             .LE. 101.
C             DEFAULTS: NDBX=25, NDBY=25, NDBZ=25
C
C  --> The grid defined here to calculate the dose distribution can be
C  used to tally other 3D distributions (e.g. the space distribution of
C  inner-shell ionisation events, used in electron-probe microanalysis).
C  This, however, requires to edit the present source file.
C
C  >>>>>>>> Job properties.
C
C  RESUME : The program will read the dump file named `dump1.dmp' (up to
C           20 characters) and resume the simulation from the point
C           where it was left. Use this option very, _VERY_ carefully.
C           Make sure that the input data file is fully consistent with
C           the one used to generate the dump file.
C             DEFAULT: off
C
C  DUMPTO : Generate a dump file named 'dump2.dmp' (up to 20 characters)
C           after completing the simulation run. This allows the
C           simulation to be resumed later on to improve statistics.
C             DEFAULT: off
C
C           NOTE: If the file 'dump2.dmp' already exists, it is
C           overwritten.
C
C  DUMPP_ : When the DUMPTO option is activated, simulation results are
C           written in the output files every DUMPP seconds. This option
C           is useful to check the progress of long simulations. It also
C           allows the program to be run with a long execution time and
C           to be stopped when the required statistical uncertainty has
C           been reached.
C             DEFAULT: DUMPP=1.0E15
C
C  RSEED_ : Seeds of the random-number generator.
C             DEFAULT: ISEED1=1, ISEED2=1
C
C  NSIMSH : Desired number of simulated showers.
C             DEFAULT: DSHN=2.0E9
C
C  TIME__ : Allotted simulation time, in sec.
C             DEFAULT: TIMEA=2.0E9
C
C  END___ : Ends the reading of the input file. This line is needed only
C           when the TIME__ line is missing.
C
C  The program is aborted when an incorrect input datum is found. The
C  conflicting quantity usually appears in the last line of the output
C  file 'penmain.dat'. If the trouble is with arrays having dimensions
C  smaller than required, the program indicates how the problem can be
C  solved (this usually requires editing the source file, be careful).
C
C  The clock subroutine (TIMER) may have to be adapted to your specific
C  computer-compiler configuration; standard Fortran 77 does not provide
C  timing tools. However, the routines in module TIMER.F do work for
C  many Fortran compilers.
C
C  ************  Generating the executable PENMAIN and running it.
C
C  To generate the executable binary file PENMAIN.EXE, compile and link
C  the Fortran source files PENMAIN.F, PENELOPE.F, PENGEOM.F, PENVARED.F
C  and TIMER.F. For example, if you are using the GNU Fortran compiler
C  under Windows, place these five files in the same directory, open a
C  command window and from that directory enter the command
C    `gfortran -Wall -Os PENMAIN.F -o PENMAIN.EXE'
C  (The same, with file names in lowercase, should work under Linux).
C
C  To run PENMAIN, you have to generate an input data file, let's call
C  it PENMAIN.IN, and the corresponding geometry definition and material
C  data files. Place these files and the binary file PEMAIN.EXE in the
C  same directory and, from there, issue the command
C    `PENMAIN.EXE < PENMAIN.IN'
C
C  The calculated distributions are written in separate files, whose
C  names have the extension '.dat'. These files are in a format suited
C  for direct visualisation with GNUPLOT (version 4.2).
C
C  *********************************************************************
C                       MAIN PROGRAM
C  *********************************************************************
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
C
      INCLUDE 'pmcomms.f'
C
C  ****  Read input files and initialize the simulation packages.
C
      CALL PMRDR
      IF(JOBEND.NE.0) GO TO 103 ! The simulation was already completed.
C
C  ****  Simulation of a new shower and scoring.
C
  101 CONTINUE
      CALL SHOWER
      IF(JOBEND.NE.0) GO TO 102  ! The simulation is completed.
C
C  ****  End the simulation after the allotted time or after completing
C        DSHN showers.
C
      CALL TIMER(TSEC)
      IF(TSEC.LT.TSECA.AND.SHN.LT.DSHN) THEN
C  ****  Write partial results after each dumping period.
        IF(LDUMP) THEN
          IF(TSEC-TSECAD.GT.DUMPP) THEN
            TSECAD=TSEC
            TSIM=TSIM+CPUTIM()-CPUT0
            CALL PMWRT(-1)
            WRITE(6,1001) SHN
 1001       FORMAT(3X,'Number of simulated showers =',1P,E14.7)
            CPUT0=CPUTIM()
            GO TO 101
          ENDIF
        ENDIF
        GO TO 101
      ENDIF
C
  102 CONTINUE
      TSIM=TSIM+CPUTIM()-CPUT0
  103 CONTINUE
      CALL PMWRT(1)
      WRITE(6,1002) SHN
 1002 FORMAT(3X,'Number of simulated showers =',1P,E14.7,
     1  /3X,'*** END ***')
      STOP
      END
C  *********************************************************************
C                       SUBROUTINE PMRDR
C  *********************************************************************
      SUBROUTINE PMRDR
C
C  Reads the input file and initializes PENELOPE and PENGEOM.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      CHARACTER*2 LIT
      CHARACTER*20 PMFILE,PFILE,PFILER
      CHARACTER*120 BUFFER,BUF2
C
      CHARACTER*6 KWORD,
     1  KWTITL,KWKPAR,KWSENE,KWSPEC,  KWSPOL,KWSPOS,KWSBOX,KWSBOD,
     1  KWSCON,KWSREC,KWPSFN,KWPSPL,  KWRRSP,KWEMAX,KWMATF,KWSIMP,
     1  KWGEOM,KWSMAX,KWEABS,KWIFOR,  KWNBE,KWNBAN,KWIDET,KWIPSF,
     1  KWISPC,KWIFLN,KWIBOD,KWIPAR,  KWEDET,KWESPC,KWEBOD,KGRDXX,
     1  KGRDYY,KGRDZZ,KGRDBN,KWRESU,  KWDUMP,KWDMPP,KWRSEE,KWNSIM,
     1  KWTIME,KWCOMM
      PARAMETER (
     1  KWTITL='TITLE ',KWKPAR='SKPAR ',KWSENE='SENERG',KWSPEC='SPECTR',
     1  KWSPOL='SGPOL ',KWSPOS='SPOSIT',KWSBOX='SBOX  ',KWSBOD='SBODY ',
     1  KWSCON='SCONE ',KWSREC='SPYRAM',KWPSFN='IPSFN ',KWPSPL='IPSPLI',
     1  KWRRSP='WGTWIN',KWEMAX='EPMAX ',KWMATF='MFNAME',KWSIMP='MSIMPA',
     1  KWGEOM='GEOMFN',KWSMAX='DSMAX ',KWEABS='EABSB ',KWIFOR='IFORCE',
     1  KWNBE ='NBE   ',KWNBAN='NBANGL',KWIDET='IMPDET',KWIPSF='IDPSF ',
     1  KWISPC='IDSPC ',KWIFLN='IDFLNC',KWIBOD='IDBODY',KWIPAR='IDKPAR',
     1  KWEDET='ENDETC',KWESPC='EDSPC ',KWEBOD='EDBODY',KGRDXX='GRIDX ',
     1  KGRDYY='GRIDY ',KGRDZZ='GRIDZ ',KGRDBN='GRIDBN',KWRESU='RESUME',
     1  KWDUMP='DUMPTO',KWDMPP='DUMPP ',KWRSEE='RSEED ',KWNSIM='NSIMSH',
     1  KWTIME='TIME  ',KWCOMM='      ')
C
      INCLUDE 'pmcomms.f'
      DIMENSION PARINP(20)
      DIMENSION PMFILE(MAXMAT)
C
      OPEN(26,FILE='penmain.dat')  ! Global output/message file.
C
      DO I=1,3
        PRIM(I)=0.0D0
        PRIM2(I)=0.0D0
        DO J=1,3
          SEC(I,J)=0.0D0
          SEC2(I,J)=0.0D0
        ENDDO
      ENDDO
C
      DO I=1,NSEM
        SHIST(I)=0.0D0
      ENDDO
C
      DO I=1,NB
        TDEBO(I)=0.0D0
        TDEBO2(I)=0.0D0
        EABSB(1,I)=50.0D0
        EABSB(2,I)=50.0D0
        EABSB(3,I)=50.0D0
      ENDDO
C
      DO I=1,3
        DO J=1,2
          DO K=1,NBEM
            PDE(I,J,K)=0.0D0
            PDE2(I,J,K)=0.0D0
            PDEP(I,J,K)=0.0D0
            LPDE(I,J,K)=0
          ENDDO
        ENDDO
      ENDDO
C
      DO I=1,3
        DO J=1,NBTHM
          DO K=1,NBPHM
            PDA(I,J,K)=0.0D0
            PDA2(I,J,K)=0.0D0
            PDAP(I,J,K)=0.0D0
            LPDA(I,J,K)=0
          ENDDO
        ENDDO
      ENDDO
C
      DO I=1,NIDM
        LDILOG(I)=.FALSE.
        DO J=1,NIDCM
          DIT(I,J)=0.0D0
          DIT2(I,J)=0.0D0
          DITP(I,J)=0.0D0
          LDIT(I,J)=0
          DO K=1,3
            DIP(I,J,K)=0.0D0
            DIP2(I,J,K)=0.0D0
            DIPP(I,J,K)=0.0D0
            LDIP(I,J,K)=0
          ENDDO
        ENDDO
      ENDDO
C
      DO I=1,NIDM
        DO J=1,NIDCM
          FST(I,J)=0.0D0
          FST2(I,J)=0.0D0
          FSTP(I,J)=0.0D0
          LFST(I,J)=0
          DO K=1,3
            FSP(I,J,K)=0.0D0
            FSP2(I,J,K)=0.0D0
            FSPP(I,J,K)=0.0D0
            LFSP(I,J,K)=0
          ENDDO
        ENDDO
      ENDDO
C
      DO I=1,NEDM
        LDELOG(I)=.FALSE.
        DO J=1,NEDCM
          DET(I,J)=0.0D0
        ENDDO
      ENDDO
C
      DO K=1,NDZM
        DO J=1,NDYM
          DO I=1,NDXM
            DOSE(I,J,K)=0.0D0
            DOSE2(I,J,K)=0.0D0
            DOSEP(I,J,K)=0.0D0
            LDOSE(I,J,K)=0
          ENDDO
        ENDDO
        DDOSE(K)=0.0D0
        DDOSE2(K)=0.0D0
        DDOSEP(K)=0.0D0
        LDDOSE(K)=0
      ENDDO
C
      CTHL=0.0D0
      DCTH=0.0D0
      PHIL=0.0D0
      DPHI=0.0D0
      DO KB=1,NB
        IXSBOD(KB)=0
      ENDDO
C
C  ****  Time counter initiation.
C
      CALL TIME0
C
C  ------------------------  Read input data file.
C
      WRITE(26,1000)
 1000 FORMAT(//3X,61('*'),/3X,'**   Program PENMAIN. ',
     1 ' Input data and run-time messages.   **',/3X,61('*'))
C
      CALL PDATET(DATE23)
      WRITE(26,1001) DATE23
 1001 FORMAT(/3X,'Date and time: ',A23)
C
C  ****  Title.
C
      READ(5,'(A6,1X,A65)') KWORD,TITLE
      IF(KWORD.EQ.KWTITL) THEN
        WRITE(26,'(/3X,A65)') TITLE
      ELSE
        WRITE(26,*) 'The input file must begin with the TITLE line.'
        STOP 'The input file must begin with the TITLE line.'
      ENDIF
C
      KPARP=1
      NPSF=0
      NPSN=0
      NSEB=1
      NSPLIT=1
      RLREAD=0.0D0
      RWGMIN=1.0D35
      KBSMAX=0
      ISEC=0
      LDUMP=.FALSE.
      LPSF=.FALSE.
      LSPEC=.FALSE.
      LGPOL=.FALSE.
      LEXSRC=.FALSE.
      LEXBD=.FALSE.
      LSCONE=.TRUE.
      JOBEND=0
C
C  ************  Source description.
C
   11 CONTINUE
      READ(5,'(A6,1X,A120)') KWORD,BUFFER
      IF(KWORD.EQ.KWCOMM) GO TO 11
      IF(KWORD.EQ.KWPSFN) GO TO 21
C
      WRITE(26,1100)
 1100 FORMAT(/3X,72('-'),/3X,'>>>>>>  Source description.')
C
      IF(KWORD.EQ.KWKPAR) THEN
        READ(BUFFER,*) KPARP
   12   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 12
        IF(KWORD.EQ.KWPSFN) GO TO 21
      ENDIF
      IF(KPARP.LT.0.OR.KPARP.GT.3) THEN
        WRITE(26,*) 'KPARP =',KPARP
        WRITE(26,*) 'Incorrect particle type.'
        STOP 'Incorrect particle type.'
      ENDIF
      IF(KPARP.EQ.1) WRITE(26,1110)
 1110 FORMAT(/3X,'Primary particles: electrons')
      IF(KPARP.EQ.2) WRITE(26,1111)
 1111 FORMAT(/3X,'Primary particles: photons')
      IF(KPARP.EQ.3) WRITE(26,1112)
 1112 FORMAT(/3X,'Primary particles: positrons')
      IF(KPARP.EQ.0) WRITE(26,1113)
 1113 FORMAT(/3X,'Primary particles: set by the user subroutine SOURCE')
C
C  ****  Monoenergetic source.
C
      IF(KWORD.EQ.KWSENE) THEN
        READ(BUFFER,*) E0
        WRITE(26,1120) E0
 1120   FORMAT(3X,'Initial energy = ',1P,E13.6,' eV')
   13   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 13
        IF(KWORD.EQ.KWPSFN) GO TO 21
C
C  ****  Continuous energy spectrum.
C
      ELSE IF(KWORD.EQ.KWSPEC) THEN
        LSPEC=.TRUE.
        NSEB=0
   14   CONTINUE
        NSEB=NSEB+1
        IF(NSEB.GT.NSEM) THEN
          WRITE(26,*) 'Source energy spectrum.'
          WRITE(26,*) 'The number of energy bins is too large.'
          STOP 'The number of energy bins is too large.'
        ENDIF
        READ(BUFFER,*) ES(NSEB),PTS(NSEB)
        PTS(NSEB)=MAX(PTS(NSEB),0.0D0)
   15   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 15
        IF(KWORD.EQ.KWSPEC) GO TO 14
        IF(KWORD.EQ.KWPSFN) GO TO 21
      ELSE
        E0=1.0D9
        IF(KPARP.NE.0) WRITE(26,1120) E0
      ENDIF
      IF(LSPEC) THEN
        IF(NSEB.GT.1) THEN
          CALL SORT2(ES,PTS,NSEB)
          WRITE(26,1121)
 1121     FORMAT(/3X,'Spectrum:',7X,'I',4X,'E_low(eV)',4x,'E_high(eV)',
     1      5X,'P_sum(E)',/16X,45('-'))
          DO I=1,NSEB-1
            WRITE(26,'(16X,I4,1P,3E14.6)') I,ES(I),ES(I+1),PTS(I)
          ENDDO
          WRITE(26,*) '  '
          E0=ES(NSEB)
          NSEB=NSEB-1
          CALL IRND0(PTS,FS,IAS,NSEB)
        ELSE
          WRITE(26,*) 'The source energy spectrum is not defined.'
          STOP 'The source energy spectrum is not defined.'
        ENDIF
      ENDIF
      IF(E0.LT.50.0D0) THEN
        WRITE(26,*) 'The initial energy E0 is too small.'
        STOP 'The initial energy E0 is too small.'
      ENDIF
      EPMAX=E0
C  ----  Positrons eventually give annihilation gamma rays. The maximum
C        energy of annihilation photons is .lt. 1.21*(E0+me*c**2).
      IF(KPARP.EQ.3) EPMAX=1.21D0*(E0+5.12D5)
C
C  ****  Photon polarisation effects (only for primary photons).
C
      IF(KWORD.EQ.KWSPOL) THEN
        READ(BUFFER,*) SP10,SP20,SP30
        LGPOL=.TRUE.
   20   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 20
        IF(KWORD.EQ.KWPSFN) GO TO 21
        WRITE(26,1131) SP10,SP20,SP30
 1131   FORMAT(/3X,'Polarised primary photons. Stokes Parameters:',
     1    /6X,'P1 = ',E13.6,' (linear polarisation at 45 deg azimuth)',
     1    /6X,'P2 = ',E13.6,' (circular polarisation)',
     1    /6X,'P3 = ',E13.6,' (linear polarisation at zero azimuth)')
      ENDIF
C
C  ****  Position of the point source.
C
      IF(KWORD.EQ.KWSPOS) THEN
        READ(BUFFER,*) SX0,SY0,SZ0
   16   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 16
        IF(KWORD.EQ.KWPSFN) GO TO 21
      ELSE
        SX0=0.0D0
        SY0=0.0D0
        SZ0=0.0D0
      ENDIF
      WRITE(26,1132) SX0,SY0,SZ0
 1132 FORMAT(/3X,'Coordinates of centre:     SX0 = ',1P,E13.6,
     1  ' cm',/30X,'SY0 = ',E13.6,' cm',/30X,'SZ0 = ',E13.6,' cm')
C
C  ****  Extended source.
C
      IF(KWORD.EQ.KWSBOX) THEN
        LEXSRC=.TRUE.
        READ(BUFFER,*) SSX,SSY,SSZ
        SSX=ABS(SSX)
        SSY=ABS(SSY)
        SSZ=ABS(SSZ)
   17   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 17
        IF(KWORD.EQ.KWPSFN) GO TO 21
      ELSE
        LEXSRC=.FALSE.
        SSX=0.0D0
        SSY=0.0D0
        SSZ=0.0D0
      ENDIF
      IF(LEXSRC) WRITE(26,1135) SSX,SSY,SSZ
 1135 FORMAT(3X,'Source size:',15X,'SSX = ',1P,E13.6,' cm',
     1  /30X,'SSY = ',E13.6,' cm',/30X,'SSZ = ',E13.6,' cm')
C
C  ****  Active bodies of an extended source.
C
  717 CONTINUE
      IF(KWORD.EQ.KWSBOD) THEN
        READ(BUFFER,*) KB
        IF(KB.LE.0.OR.KB.GT.NB) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect body label.'
          STOP 'Incorrect body label.'
        ENDIF
        WRITE(26,7620) KB
 7620   FORMAT(3X,'Active body = ',I4)
        IXSBOD(KB)=1
        LEXBD=.TRUE.
        KBSMAX=MAX(KBSMAX,KB)
  766   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 766
        IF(KWORD.EQ.KWSBOD) GO TO 717
      ENDIF
C
C  ****  Angular distribution of primary particles.
C
      ISOURC=0
  777 CONTINUE
      IF(KWORD.EQ.KWSCON) THEN
        LSCONE=.TRUE.
        READ(BUFFER,*) STHETA,SPHI,SALPHA
        IF(STHETA.LT.-1.0D-9.OR.STHETA-180.0D0.GT.1.0D-9) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,'(/3X,''THETA must be between 0 and 180 deg.'')')
          STOP 'THETA must be between 0 and 180 deg'
        ENDIF
        IF(SPHI.LT.-1.0D-9.OR.SPHI-360.0D0.GT.1.0D-9) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,'(/3X,''PHI must be between 0 and 360 deg.'')')
          STOP 'PHI must be between 0 and 360 deg'
        ENDIF
        IF(SALPHA.LT.-1.0D-9.OR.SALPHA-180.0D0.GT.1.0D-9) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,'(/3X,''ALPHA must be between 0 and 180 deg.'')')
          STOP 'ALPHA must be between 0 and 180 deg'
        ENDIF
        CALL GCONE0(STHETA*DE2RA,SPHI*DE2RA,SALPHA*DE2RA)
        ISOURC=1
   18   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 18
        IF(KWORD.EQ.KWPSFN) GO TO 721
        GO TO 777
      ELSE IF(KWORD.EQ.KWSREC) THEN
        LSCONE=.FALSE.
        READ(BUFFER,*) THETLD,THETUD,PHILD,PHIUD
        IF(MIN(THETLD,THETUD).LT.-1.0D-9.OR.
     1     MAX(THETLD,THETUD)-180.0D0.GT.1.0D-9) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,'(/3X,''THETA must be between 0 and 180 deg.'')')
          STOP 'THETA must be between 0 and 180 deg'
        ENDIF
        IF(MIN(PHILD,PHIUD).LT.-1.0D-9.OR.
     1     MAX(PHILD,PHIUD)-360.0D0.GT.1.0D-9) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,'(/3X,''PHI must be between 0 and 360 deg.'')')
          STOP 'PHI must be between 0 and 360 deg'
        ENDIF
        CTHL=COS(THETLD*DE2RA)
        DCTH=COS(THETUD*DE2RA)-CTHL
        PHIL=PHILD*DE2RA
        DPHI=PHIUD*DE2RA-PHIL
        ISOURC=1
   19   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 19
        IF(KWORD.EQ.KWPSFN) GO TO 721
        GO TO 777
      ELSE IF(ISOURC.EQ.0) THEN
        LSCONE=.TRUE.
        STHETA=0.0D0
        SPHI=0.0D0
        SALPHA=0.0D0
        CALL GCONE0(STHETA*DE2RA,SPHI*DE2RA,SALPHA*DE2RA)
      ENDIF
C
  721 CONTINUE
      IF(LSCONE) THEN
        WRITE(26,1133) STHETA,SPHI
 1133   FORMAT(/3X,'*** Conical beam:'
     1    /3X,'Beam axis direction:     THETA = ',1P,E13.6,' deg',
     1    /30X,'PHI = ',E13.6,' deg')
        WRITE(26,1134) SALPHA
 1134   FORMAT(3X,'Beam aperture:',11X,'ALPHA = ',1P,E13.6,' deg')
      ELSE
        WRITE(26,1733) THETLD,THETUD,PHILD,PHIUD
 1733   FORMAT(/3X,'*** Rectangular beam:'
     1    /3X,'Angular window: THETA = (',1P,E13.6,',',E13.6,') deg',
     1    /21X,'PHI = (',E13.6,',',E13.6,') deg')
      ENDIF
C
C  ************  Particle state variables read from a phase-space file.
C
   21 CONTINUE
      IF(KWORD.EQ.KWPSFN) THEN
        IF(KPARP.EQ.0) THEN
          WRITE(26,'(/3X,''With KPARP=0 (subroutine SOURCE activat'',
     1      ''ed),'')')
          WRITE(26,'(3X,''we cannot read particles from a phase-'',
     1      ''space file.'')')
          STOP 'Inconsistent definition of the primary source.'
        ENDIF
        NPSF=NPSF+1
        IF(NPSF.EQ.1) THEN
          WRITE(26,1200)
 1200     FORMAT(/3X,72('-'),/3X,'>>>>>>  Input phase-space files.'/)
        ENDIF
        IF(NPSF.GT.NPSFM) THEN
          WRITE(26,'(/3X,''Too many phase-space files.'')')
          STOP 'Too many phase-space files'
        ENDIF
        READ(BUFFER,'(A20)') PSFI(NPSF)
        WRITE(26,1201) NPSF,PSFI(NPSF)
 1201   FORMAT(3X,'Phase-space file #',I4,': ',A20)
        LPSF=.TRUE.
        LSPEC=.FALSE.
   22   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 22
        IF(KWORD.EQ.KWPSFN) GO TO 21
C
        IF(KWORD.EQ.KWPSPL) THEN
          READ(BUFFER,*) NSPLIT
          IF(NSPLIT.GT.1.AND.NSPLIT.LE.1000) THEN
            WRITE(26,1210) NSPLIT
 1210       FORMAT(/3X,'Particle splitting number = ',I3)
          ELSE
            NSPLIT=MIN(1000,ABS(NSPLIT))
            WRITE(26,1211) NSPLIT
 1211       FORMAT(/3X,'Particle splitting number = ',I3,
     1        ' (modified)')
          ENDIF
   23     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 23
        ENDIF
C
        IF(KWORD.EQ.KWRRSP) THEN
          READ(BUFFER,*) WGMIN,WGMAX
          WGMIN=ABS(WGMIN)
          WGMAX=MIN(ABS(WGMAX),1.0D10)
          IF(WGMIN.GT.WGMAX) THEN
            WRITE(26,*) 'WGMIN =',WGMIN
            WRITE(26,*) 'WGMAX =',WGMAX
            WRITE(26,'(/3X,''Inconsistent window end points.'')')
            STOP 'Inconsistent window end points.'
          ENDIF
          WRITE(26,1291) WGMIN,WGMAX
 1291     FORMAT(/3X,'Initial weight window = (',1P,E13.6,',',
     1      E13.6,')')
   24     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 24
        ENDIF
        RWGMIN=1.0D0/WGMIN
      ENDIF
C
      IF(KPARP.EQ.0) THEN
        LSPEC=.TRUE.  ! Generate the energy spectrum from the source.
        CALL SOURCE
        IF(LSPEC) THEN
          NSEB=200
          DSHE=1.000000001D0*EPMAX/DBLE(NSEB)
          RDSHE=1.0D0/DSHE
        ENDIF
      ENDIF
C
C  ****  Maximum particle energy.
C
      IF(KWORD.EQ.KWEMAX) THEN
        READ(BUFFER,*) EPMAXR
        IF(KPARP.NE.0) EPMAX=EPMAXR
        WRITE(26,1220) EPMAX
 1220   FORMAT(/3X,'Maximum particle energy = ',1P,E13.6,' eV')
   25   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 25
      ELSE
        IF(LPSF) THEN
          EPMAX=1.0D9
          WRITE(26,1220) EPMAX
          WRITE(26,'(3X,''WARNING: You should have specified the '',
     1      ''maximum energy EPMAX.'')')
        ENDIF
        WRITE(26,1220) EPMAX
      ENDIF
C
C  ************  Material data and simulation parameters.
C
      WRITE(26,1300)
 1300 FORMAT(/3X,72('-'),/
     1  3X,'>>>>>>  Material data and simulation parameters.')
C
C  ****  Simulation parameters.
C
      DO M=1,MAXMAT
        EABS(1,M)=0.010D0*EPMAX
        EABS(2,M)=0.001D0*EPMAX
        EABS(3,M)=0.010D0*EPMAX
        C1(M)=0.10D0
        C2(M)=0.10D0
        WCC(M)=EABS(1,M)
        WCR(M)=EABS(2,M)
      ENDDO
      DO IB=1,NB
        DSMAX(IB)=1.0D20
      ENDDO
C
      NMAT=0
   31 CONTINUE
      IF(KWORD.EQ.KWMATF) THEN
        NMAT=NMAT+1
        READ(BUFFER,'(A20)') PMFILE(NMAT)
   32   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 32
        IF(KWORD.EQ.KWMATF) GO TO 31
      ENDIF
C
      IF(KWORD.EQ.KWSIMP) THEN
        READ(BUFFER,*) EABS(1,NMAT),EABS(2,NMAT),EABS(3,NMAT),
     1    C1(NMAT),C2(NMAT),WCC(NMAT),WCR(NMAT)
   33   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 33
        IF(KWORD.EQ.KWMATF) GO TO 31
      ENDIF
C
      IF(NMAT.EQ.0) THEN
        WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
        WRITE(26,*) 'You have to specify a material file (line MFNAME).'
        STOP 'You have to specify a material file (line MFNAME).'
      ENDIF
      IF(NMAT.GT.MAXMAT) THEN
        WRITE(26,*) 'Wrong number of materials.'
        WRITE(26,'(''NMAT ='',I4,'' is larger than MAXMAT ='',I4)')
     1    NMAT,MAXMAT
        STOP 'Wrong number of materials.'
      ENDIF
C
      DO M=1,NMAT
        IF(M.EQ.1) LIT='st'
        IF(M.EQ.2) LIT='nd'
        IF(M.EQ.3) LIT='rd'
        IF(M.GT.3) LIT='th'
        WRITE(26,1320) M,LIT
 1320   FORMAT(/3X,'**** ',I2,A2,' material')
        WRITE(26,1325) PMFILE(M)
 1325   FORMAT(3X,'Material data file: ',A)
        IF(EABS(1,M).LT.5.0D1) EABS(1,M)=5.0D1
        IF(EABS(2,M).LT.5.0D1) EABS(2,M)=5.0D1
        IF(EABS(3,M).LT.5.0D1) EABS(3,M)=5.0D1
        WRITE(26,1321) EABS(1,M)
 1321   FORMAT(3X,'Electron absorption energy = ',1P,E13.6,' eV')
        WRITE(26,1322) EABS(2,M)
 1322   FORMAT(3X,'  Photon absorption energy = ',1P,E13.6,' eV')
        WRITE(26,1323) EABS(3,M)
 1323   FORMAT(3X,'Positron absorption energy = ',1P,E13.6,' eV')
        WRITE(26,1324) C1(M),C2(M),WCC(M),WCR(M)
 1324   FORMAT(3X,'Electron-positron simulation parameters:',
     1    /4X,'C1 =',1P,E13.6,',      C2 =',E13.6,/3X,'Wcc =',E13.6,
     1    ' eV,  Wcr =',E13.6,' eV')
      ENDDO
C
C  ****  Initialisation of PENELOPE.
C
      WRITE(6,*) '  Initialising PENELOPE ...'
      IWR=16
      OPEN(IWR,FILE='material.dat')
        INFO=1
        CALL PEINIT(EPMAX,NMAT,IWR,INFO,PMFILE)
      CLOSE(IWR)
C  ----  Inverse densities are used to score the local dose.
      DO M=1,NMAT
        RHOI(M)=1.0D0/RHO(M)
      ENDDO
C
C  ************  Geometry definition.
C
C  Define here the geometry parameters that are to be altered, if any.
C     PARINP(1)=
C     PARINP(2)=  ...
      NPINP=0
C
      WRITE(6,*) '  Initialising PENGEOM ...'
      IF(KWORD.EQ.KWGEOM) THEN
        READ(BUFFER,'(A20)') PFILE
        WRITE(26,1340) PFILE
 1340   FORMAT(/3X,72('-'),/3X,'>>>>>>  Geometry definition.',
     1    /3X,'PENGEOM''s geometry file: ',A20)
        OPEN(15,FILE=PFILE,IOSTAT=KODE)
        IF(KODE.NE.0) THEN
          WRITE(26,'(''File '',A20,'' could not be opened.'')') PFILE
          STOP
        ENDIF
        OPEN(16,FILE='geometry.rep')
        CALL GEOMIN(PARINP,NPINP,NMATG,NBODY,15,16)
        CLOSE(15)
        CLOSE(16)
        IF(NMATG.LT.1) THEN
          WRITE(26,*) 'NMATG must be greater than 0.'
          STOP 'NMATG must be greater than 0.'
        ENDIF
C
        IF(NBODY.GT.NB) THEN
          WRITE(26,'(/6X,''Too many bodies.'')')
          STOP 'Too many bodies.'
        ENDIF
C
        IF(NMATG.GT.NMAT) THEN
          WRITE(26,'(/6X,''Too many different materials.'')')
          STOP 'Too many different materials.'
        ENDIF
C
        IF(KBSMAX.GT.NBODY) THEN
          WRITE(26,'(/6X,''KBSMAX = '',I4)') KBSMAX
          WRITE(26,'(6X,'' NBODY = '',I4)') NBODY
          WRITE(26,'(6X,''Some source bodies are undefined. STOP.'')')
          STOP 'Some source bodies are undefined.'
        ENDIF
C
   34   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 34
      ELSE
        WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
        WRITE(26,*) 'You have to specify a geometry file.'
        STOP 'You have to specify a geometry file.'
      ENDIF
C
C  ****  Maximum step lengths of electrons and positrons.
C
      IF(KWORD.EQ.KWSMAX) THEN
        READ(BUFFER,*) IB
        IF(IB.LT.1.OR.IB.GT.NBODY) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect body number.'
          STOP 'Incorrect body number.'
        ENDIF
        READ(BUFFER,*) IB,DSMAX(IB)
        IF(DSMAX(IB).LT.1.0D-7) DSMAX(IB)=1.0D20
   35   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 35
        IF(KWORD.EQ.KWSMAX) THEN
          READ(BUFFER,*) IB
          IF(IB.LT.1.OR.IB.GT.NBODY) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'Incorrect body number.'
            STOP 'Incorrect body number.'
          ENDIF
          READ(BUFFER,*) IB,DSMAX(IB)
          IF(DSMAX(IB).LT.1.0D-7) DSMAX(IB)=1.0D20
          GO TO 35
        ENDIF
      ENDIF
C
C  ****  Local absorption energies (useful to reduce simulation work
C        in regions of lesser interest).
C
      DO IB=1,NBODY
        M=MATER(IB)
        IF(M.GT.0) THEN
          EABSB(1,IB)=EABS(1,M)
          EABSB(2,IB)=EABS(2,M)
          EABSB(3,IB)=EABS(3,M)
        ENDIF
      ENDDO
C
      IF(KWORD.EQ.KWEABS) THEN
   36   CONTINUE
        READ(BUFFER,*) IB
        IF(IB.LT.1.OR.IB.GT.NBODY) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect body number.'
          STOP 'Incorrect body number.'
        ENDIF
        READ(BUFFER,*) JB,EAB1,EAB2,EAB3
        IF(MATER(IB).GT.0) THEN
          EABSB(1,IB)=MAX(EABSB(1,IB),EAB1)
          EABSB(2,IB)=MAX(EABSB(2,IB),EAB2)
          EABSB(3,IB)=MAX(EABSB(3,IB),EAB3)
        ENDIF
   37   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 37
        IF(KWORD.EQ.KWEABS) GO TO 36
      ENDIF
C
      WRITE(26,1350)
 1350 FORMAT(/9X,'Maximum allowed step lengths of',
     1  ' electrons and positrons',/9X,'and local absorption ',
     2  'energies (non-void bodies).',
     3  //3X,'Body',3X,'DSMAX(IB)',4X,'EABSB(1,IB)',3X,
     3  'EABSB(2,IB)',3X,'EABSB(3,IB)',/4X,'IB',7X,'(cm)',10X,'(eV)',
     4  10X,'(eV)',10X,'(eV)')
      DO IB=1,NBODY
        IF(MATER(IB).GT.0) WRITE(26,1351) IB,DSMAX(IB),EABSB(1,IB),
     1    EABSB(2,IB),EABSB(3,IB)
 1351   FORMAT(3X,I4,1P,4E14.6)
      ENDDO
C
C  ************  Variance reduction (only interaction forcing).
C
      DO KB=1,NB
        DO ICOL=1,8
          DO KPAR=1,3
            FORCE(KB,KPAR,ICOL)=1.0D0
          ENDDO
        ENDDO
        DO KPAR=1,3
          LFORCE(KB,KPAR)=.FALSE.
          WLOW(KB,KPAR)=0.0D0
          WHIG(KB,KPAR)=1.0D6
        ENDDO
      ENDDO
C
      IF(KWORD.EQ.KWIFOR) THEN
        WRITE(26,1400)
 1400   FORMAT(/3X,72('-'),/
     1    3X,'>>>>>>  Interaction forcing: FORCE(IBODY,KPAR,ICOL)')
   41   CONTINUE
        READ(BUFFER,*) KB,KPAR,ICOL,FORCER,WWLOW,WWHIG
C  ****  Negative FORCER values are re-interpreted, as described in the
C        heading comments above.
        IF(FORCER.LT.-1.0D-6) THEN
          MM=MATER(KB)
          EVENTS=MAX(ABS(FORCER),1.0D0)
          PLT=PRANGE(E0,KPAR,MM)
          RMFP=PHMFP(E0,KPAR,MM,ICOL)
          IF(RMFP.LT.1.0D25) THEN
            FORCER=EVENTS*RMFP/PLT
          ELSE
            FORCER=1.0D0
          ENDIF
        ENDIF
        IF(WWLOW.LT.1.0D-6) WWLOW=1.0D-6
        IF(WWHIG.GT.1.0D6) WWHIG=1.0D6
        IF(KB.LT.1.OR.KB.GT.NBODY) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect KB value.'
          STOP 'Incorrect KB value.'
        ENDIF
        IF(KPAR.LT.1.OR.KPAR.GT.3) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect value of KPAR.'
          STOP 'Incorrect value of KPAR.'
        ENDIF
        IF(ICOL.LT.1.OR.ICOL.GT.8) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect value of ICOL.'
          STOP 'Incorrect value of ICOL.'
        ENDIF
        WLOW(KB,KPAR)=MAX(WLOW(KB,KPAR),WWLOW)
        WHIG(KB,KPAR)=MIN(WHIG(KB,KPAR),WWHIG)
        IF(WLOW(KB,KPAR).GT.WHIG(KB,KPAR)) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect weight window limits.'
          STOP 'Incorrect weight window limits.'
        ENDIF
        IF(FORCER.GT.1.0001D0) THEN
          LFORCE(KB,KPAR)=.TRUE.
          FORCE(KB,KPAR,ICOL)=FORCER
          WRITE(26,1410) KB,KPAR,ICOL,FORCER,WLOW(KB,KPAR),WHIG(KB,KPAR)
 1410     FORMAT(3X,'FORCE(',I4,',',I1,',',I1,') =',1P,E13.6,
     1      ',  weight window = (',E9.2,',',E9.2,')')
        ENDIF
   42   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 42
        IF(KWORD.EQ.KWIFOR) GO TO 41
      ENDIF
C
C  ************  Energy and angular distributions of emerging
C                particles.
C
      WRITE(26,1500)
 1500 FORMAT(/3X,72('-'),/
     1  3X,'>>>>>>  Energy and angular distributions of emerging',
     1  ' particles.')
C
      IF(KWORD.EQ.KWNBE) THEN
        READ(BUFFER,*) EMIN,EMAX,NBE
   51   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 51
      ELSE
        EMIN=0.0D0
        EMAX=EPMAX
        NBE=100
      ENDIF
      EMIN=MAX(EMIN,0.0D0)
      EMAX=MAX(EMIN+50.0D0,EMAX)
      WRITE(26,1510) NBE,EMIN,EMAX
 1510 FORMAT(3X,'E:       NBE = ',I3,
     1  ',  EMIN =',1P,E13.6,' eV,  EMAX =',E13.6,' eV')
      IF(NBE.LT.1) THEN
        WRITE(26,*) 'Wrong number of energy bins.'
        STOP 'Wrong number of energy bins.'
      ELSE IF (NBE.GT.NBEM) THEN
        WRITE(26,*) 'NBE is too large.'
        WRITE(26,*) 'Set the parameter NBEM equal to ',NBE
        STOP 'NBE is too large.'
      ENDIF
C
      IF(KWORD.EQ.KWNBAN) THEN
        READ(BUFFER,*) NBTH,NBPH
   52   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 52
      ELSE
        NBTH=90
        NBPH=1
      ENDIF
      WRITE(26,1520) NBTH
 1520 FORMAT(3X,'Theta:  NBTH = ',I3)
      WRITE(26,1530) NBPH
 1530 FORMAT(3X,'Phi:    NBPH = ',I3)
      IF(NBTH.LT.1) THEN
        WRITE(26,*) 'Wrong number of THETA bins.'
        STOP 'Wrong number of THETA bins.'
      ELSE IF (NBTH.GT.NBTHM) THEN
        WRITE(26,*) 'NBTH is too large.'
        WRITE(26,*) 'Set the parameter NBTHM equal to ',NBTH
        STOP 'NBTH is too large.'
      ENDIF
      IF(NBPH.LT.1) THEN
        WRITE(26,*) 'Wrong number of PHI bins.'
        STOP 'Wrong number of PHI bins.'
      ELSE IF (NBPH.GT.NBPHM) THEN
        WRITE(26,*) 'NBPH is too large.'
        WRITE(26,*) 'Set the parameter NBPHM equal to ',NBPH
        STOP 'NBPH is too large.'
      ENDIF
C
C  ****  Bin sizes.
C  ----  The factor FSAFE=1.000000001 serves to ensure that the upper
C  limit of the tallied interval is within the last bin (otherwise, the
C  array dimensions could be exceeded).
C
      FSAFE=1.000000001D0
      BSE=FSAFE*(EMAX-EMIN)/DBLE(NBE)
      RBSE=1.0D0/BSE
      BSTH=FSAFE*180.0D0/DBLE(NBTH)
      RBSTH=1.0D0/BSTH
      BSPH=FSAFE*360.0D0/DBLE(NBPH)
      RBSPH=1.0D0/BSPH
C
C  ************  Impact detectors.
C
      DO KD=1,NIDM
        KKDI(KD,1)=0
        KKDI(KD,2)=0
        KKDI(KD,3)=0
        TDID(KD)=0.0D0
        TDID2(KD)=0.0D0
      ENDDO
      NDBOD=0
      NPSFO=0
C
      NDIDEF=0
   61 CONTINUE
      IF(KWORD.EQ.KWIDET) THEN
        NDIDEF=NDIDEF+1
        NDBOD=0
        IF(NDIDEF.GT.NIDM) THEN
          WRITE(26,'(3X,''NDIDEF = '',I4)') NDIDEF
          WRITE(26,*) 'Too many detectors.'
          STOP 'Too many detectors.'
        ENDIF
        WRITE(26,1600) NDIDEF
 1600   FORMAT(/3X,72('-'),/
     1    3X,'>>>>>>  Impact detector #', I2)
        READ(BUFFER,*) EDIL(NDIDEF),EDIU(NDIDEF),NDICH(NDIDEF),
     1    IPSF(NDIDEF),IDCUT(NDIDEF)
        IF(EDIL(NDIDEF).LT.0.0D0) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'EDIL must be positive.'
          STOP 'EDIL must be positive.'
        ENDIF
        IF(EDIU(NDIDEF).LT.EDIL(NDIDEF)) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect energy limits.'
          STOP 'Incorrect energy limits.'
        ENDIF
        IF(NDICH(NDIDEF).LT.0) THEN
          LDILOG(NDIDEF)=.TRUE.  ! Logarithmic bins.
          NDICH(NDIDEF)=ABS(NDICH(NDIDEF))
        ENDIF
        IF(NDICH(NDIDEF).LT.10.OR.NDICH(NDIDEF).GT.NIDCM) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect number of energy bins.'
          STOP 'Incorrect number of energy bins.'
        ENDIF
C
        IF(LDILOG(NDIDEF)) THEN
          WRITE(26,1614) EDIL(NDIDEF),EDIU(NDIDEF),NDICH(NDIDEF)
 1614     FORMAT(3X,'Energy window = (',1P,E12.5,',',E12.5,') eV',
     1      /3X,'Number of energy bins = ',I4,'  (logarithmic mesh)')
          EDIUL(NDIDEF)=LOG(EDIU(NDIDEF))
          EDILL(NDIDEF)=LOG(EDIL(NDIDEF))
          BDIEL(NDIDEF)=FSAFE*(EDIUL(NDIDEF)-EDILL(NDIDEF))
     1      /DBLE(NDICH(NDIDEF))
          RBDIEL(NDIDEF)=1.0D0/BDIEL(NDIDEF)
        ELSE
          WRITE(26,1610) EDIL(NDIDEF),EDIU(NDIDEF),NDICH(NDIDEF)
 1610     FORMAT(3X,'Energy window = (',1P,E12.5,',',E12.5,') eV',
     1      /3X,'Number of energy bins = ',I4,'  (uniform mesh)')
          BDIE(NDIDEF)=FSAFE*(EDIU(NDIDEF)-EDIL(NDIDEF))
     1      /DBLE(NDICH(NDIDEF))
          RBDIE(NDIDEF)=1.0D0/BDIE(NDIDEF)
        ENDIF
C
        IF(IPSF(NDIDEF).LT.0.OR.ABS(IPSF(NDIDEF)).GT.1) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Wrong IPSF value.'
          STOP 'Wrong IPSF value.'
        ENDIF
C
        IF(IDCUT(NDIDEF).LT.0.OR.ABS(IDCUT(NDIDEF)).GT.2) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Wrong IDCUT value.'
          STOP 'Wrong IDCUT value.'
        ENDIF
C
   62   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 62
C
        IF(KWORD.EQ.KWISPC) THEN
          IF(NDIDEF.EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'No impact detector has been defined yet.'
            STOP 'No impact detector has been defined yet.'
          ENDIF
          READ(BUFFER,'(A20)') SPCDIO(NDIDEF)
          WRITE(26,1612) SPCDIO(NDIDEF)
 1612     FORMAT(3X,'Output energy spectrum: ',A20)
   64     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 64
        ELSE
          WRITE(BUF2,'(I5)') 1000+NDIDEF
          SPCDIO(NDIDEF)='spc-impdet-'//BUF2(4:5)//'.dat'
          WRITE(26,1612) SPCDIO(NDIDEF)
        ENDIF
C
        IF(KWORD.EQ.KWIPSF) THEN
          IF(NDIDEF.EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'No impact detector has been defined yet.'
            STOP 'No impact detector has been defined yet.'
          ENDIF
          READ(BUFFER,'(A20)') PSFDIO(NDIDEF)
          IF(IPSF(NDIDEF).GT.0) THEN
            WRITE(26,1611) PSFDIO(NDIDEF)
 1611       FORMAT(3X,'Output phase-space file: ',A20)
            NPSFO=NPSFO+1
            IF(NPSFO.GT.1) THEN
              WRITE(26,*) 'You cannot generate more than one PSF in ',
     1          'a single run.'
              STOP 'Only one PSF can be generated in a each run.'
            ENDIF
          ELSE
            WRITE(26,1613)
 1613       FORMAT(3X,'No phase-space file is generated.')
          ENDIF
   63     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 63
        ELSE
          IF(IPSF(NDIDEF).GT.0) THEN
            WRITE(BUF2,'(I5)') 1000+NDIDEF
            PSFDIO(NDIDEF)='psf-impdet-'//BUF2(4:5)//'.dat'
            WRITE(26,1611) PSFDIO(NDIDEF)
            NPSFO=NPSFO+1
            IF(NPSFO.GT.1) THEN
              WRITE(26,*) 'You cannot generate more than one PSF in ',
     1          'a single run.'
              STOP 'Only one PSF can be generated in each run.'
            ENDIF
          ENDIF
        ENDIF
C
        IF(ABS(IDCUT(NDIDEF)).EQ.0) THEN
          WRITE(26,1601)
 1601     FORMAT(3X,'Detected particles are absorbed')
        ELSE
          WRITE(26,1602)
 1602     FORMAT(3X,'Particles are transported through this detector')
        ENDIF
C
        IF(KWORD.EQ.KWIFLN) THEN
          IF(NDIDEF.EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'No impact detector has been defined yet.'
            STOP 'No impact detector has been defined yet.'
          ENDIF
          READ(BUFFER,'(A20)') SPCFSO(NDIDEF)
   83     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 83
          IF(IDCUT(NDIDEF).EQ.2) THEN
            WRITE(26,1662) SPCFSO(NDIDEF)
 1662       FORMAT(3X,'Output fluence distribution: ',A20)
          ENDIF
        ELSE
          IF(IDCUT(NDIDEF).EQ.2) THEN
            WRITE(BUF2,'(I5)') 1000+NDIDEF
            SPCFSO(NDIDEF)='fln-impdet-'//BUF2(4:5)//'.dat'
            WRITE(26,1662) SPCFSO(NDIDEF)
          ENDIF
        ENDIF
C
   65   CONTINUE
        IF(KWORD.EQ.KWIBOD) THEN
          IF(NDIDEF.EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'No impact detector has been defined yet.'
            STOP 'No impact detector has been defined yet.'
          ENDIF
          READ(BUFFER,*) KB
          IF(KB.LE.0.OR.KB.GT.NBODY) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'Incorrect body label.'
            STOP 'Incorrect body label.'
          ENDIF
          IF(KDET(KB).NE.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'A body cannot be part of two detectors.'
            STOP 'A body cannot be part of two detectors.'
          ENDIF
          IF(MATER(KB).EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'A void body cannot be part of a detector.'
            STOP 'A void body cannot be part of a detectors.'
          ENDIF
          WRITE(26,1620) KB
 1620     FORMAT(3X,'Active body = ',I4)
          KDET(KB)=NDIDEF
          NDBOD=NDBOD+1
   66     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 66
          IF(KWORD.EQ.KWIBOD) GO TO 65
          IF(KWORD.EQ.KWIDET) THEN
            ITST=MAX(KKDI(NDIDEF,1),KKDI(NDIDEF,2),KKDI(NDIDEF,3))
            IF(ITST.EQ.0) THEN
              KKDI(NDIDEF,1)=1
              KKDI(NDIDEF,2)=1
              KKDI(NDIDEF,3)=1
              WRITE(26,1630)
 1630         FORMAT(3X,'Detected particles = electrons, photons and ',
     1          'positrons')
            ENDIF
            IF(NDBOD.EQ.0) THEN
              WRITE(26,*) 'This detector has no active bodies.'
              STOP 'This detector has no active bodies.'
            ENDIF
            GO TO 61
          ENDIF
        ENDIF
C
   67   CONTINUE
        IF(KWORD.EQ.KWIPAR) THEN
          IF(NDIDEF.EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'No impact detector has been defined yet.'
            STOP 'No impact detector has been defined yet.'
          ENDIF
          IF(NDBOD.EQ.0) THEN
            WRITE(26,*) 'This detector has no active bodies.'
            STOP 'This detector has no active bodies.'
          ENDIF
C
          READ(BUFFER,*) KPARD
          IF(KPARD.EQ.1) THEN
            KKDI(NDIDEF,1)=1
            WRITE(26,1631)
 1631       FORMAT(3X,'Detected particles = electrons')
          ELSE IF(KPARD.EQ.2) THEN
            KKDI(NDIDEF,2)=1
            WRITE(26,1632)
 1632       FORMAT(3X,'Detected particles = photons')
          ELSE IF(KPARD.EQ.3) THEN
            KKDI(NDIDEF,3)=1
            WRITE(26,1633)
 1633       FORMAT(3X,'Detected particles = positrons')
          ENDIF
   68     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 68
          IF(KWORD.EQ.KWIPAR) GO TO 67
          IF(KWORD.EQ.KWIBOD) GO TO 65
          IF(KWORD.EQ.KWIDET) THEN
            ITST=MAX(KKDI(NDIDEF,1),KKDI(NDIDEF,2),KKDI(NDIDEF,3))
            IF(ITST.EQ.0) THEN
              KKDI(NDIDEF,1)=1
              KKDI(NDIDEF,2)=1
              KKDI(NDIDEF,3)=1
              WRITE(26,1630)
            ENDIF
            GO TO 61
          ENDIF
        ENDIF
      ENDIF
C
      IF(NDIDEF.GT.0) THEN
        IF(NDBOD.EQ.0) THEN
          WRITE(26,*) 'This detector has no active bodies.'
          STOP 'This detector has no active bodies.'
        ENDIF
        ITST=MAX(KKDI(NDIDEF,1),KKDI(NDIDEF,2),KKDI(NDIDEF,3))
        IF(ITST.EQ.0) THEN
          KKDI(NDIDEF,1)=1
          KKDI(NDIDEF,2)=1
          KKDI(NDIDEF,3)=1
          WRITE(26,1630)
        ENDIF
      ENDIF
C
C  ************  Energy-deposition detectors.
C
      DO KB=1,NBODY
        KBDE(KB)=0
      ENDDO
      DO KD=1,NEDM
        TDED(KD)=0.0D0
        TDED2(KD)=0.0D0
      ENDDO
      NDBOD=0
C
      NDEDEF=0
   43 CONTINUE
      IF(KWORD.EQ.KWEDET) THEN
        IF(NDEDEF.GT.0) THEN
          IF(NDBOD.EQ.0) THEN
            WRITE(26,*) 'This detector has no active bodies.'
            STOP 'This detector has no active bodies.'
          ENDIF
        ENDIF
        NDEDEF=NDEDEF+1
        NDBOD=0
        IF(NDEDEF.GT.NEDM) THEN
          WRITE(26,'(3X,''NDEDEF = '',I4)') NDEDEF
          WRITE(26,*) 'Too many energy-deposition detectors.'
          STOP 'Too many energy-deposition detectors.'
        ENDIF
        WRITE(26,1650) NDEDEF
 1650   FORMAT(/3X,72('-'),/
     1    3X,'>>>>>>  Energy-deposition detector #', I2)
        READ(BUFFER,*) EDEL(NDEDEF),EDEU(NDEDEF),NDECH(NDEDEF)
        IF(EDEL(NDEDEF).LT.0.0D0) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'EDEL must be positive.'
          STOP 'EDEL must be positive.'
        ENDIF
        IF(EDEU(NDEDEF).LT.EDEL(NDEDEF)) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect energy limits.'
          STOP 'Incorrect energy limits.'
        ENDIF
        IF(NDECH(NDEDEF).LT.0) THEN
          LDELOG(NDEDEF)=.TRUE.  ! Logarithmic bins.
          NDECH(NDEDEF)=ABS(NDECH(NDEDEF))
        ENDIF
        IF(NDECH(NDEDEF).LT.10.OR.NDECH(NDEDEF).GT.NEDCM) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Incorrect number of bins.'
          STOP 'Incorrect number of bins.'
        ENDIF
C
        IF(LDELOG(NDEDEF)) THEN
          WRITE(26,1614) EDEL(NDEDEF),EDEU(NDEDEF),NDECH(NDEDEF)
          EDEUL(NDEDEF)=LOG(EDEU(NDEDEF))
          EDELL(NDEDEF)=LOG(EDEL(NDEDEF))
          BDEEL(NDEDEF)=FSAFE*(EDEUL(NDEDEF)-EDELL(NDEDEF))
     1      /DBLE(NDECH(NDEDEF))
          RBDEEL(NDEDEF)=1.0D0/BDEEL(NDEDEF)
        ELSE
          WRITE(26,1610) EDEL(NDEDEF),EDEU(NDEDEF),NDECH(NDEDEF)
          BDEE(NDEDEF)=FSAFE*(EDEU(NDEDEF)-EDEL(NDEDEF))
     1      /DBLE(NDECH(NDEDEF))
          RBDEE(NDEDEF)=1.0D0/BDEE(NDEDEF)
        ENDIF
C
   44   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 44
        IF(KWORD.EQ.KWESPC) THEN
          READ(BUFFER,'(A20)') SPCDEO(NDEDEF)
          WRITE(26,1651) SPCDEO(NDEDEF)
 1651     FORMAT(3X,'Output spectrum: ',A20)
   45     CONTINUE
          READ(5,'(A6,1X,A120)') KWORD,BUFFER
          IF(KWORD.EQ.KWCOMM) GO TO 45
        ELSE
          WRITE(BUF2,'(I5)') 1000+NDEDEF
          SPCDEO(NDEDEF)='spc-enddet-'//BUF2(4:5)//'.dat'
          WRITE(26,1651) SPCDEO(NDEDEF)
        ENDIF
C
   46   CONTINUE
        IF(KWORD.EQ.KWEBOD) THEN
          READ(BUFFER,*) KB
          IF(KB.LT.0.OR.KB.GT.NBODY) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'Incorrect body label.'
            STOP 'Incorrect body label.'
          ENDIF
          IF(KBDE(KB).NE.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'A body cannot be part of two detectors.'
            STOP 'A body cannot be part of two detectors.'
          ENDIF
          IF(MATER(KB).EQ.0) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'A void body cannot be part of a detector.'
            STOP 'A void body cannot be part of a detectors.'
          ENDIF
          WRITE(26,1652) KB
 1652     FORMAT(3X,'Active body = ',I4)
          IF(LFORCE(KB,1).OR.LFORCE(KB,2).OR.LFORCE(KB,3)) THEN
            WRITE(26,'(3X,''#  WARNING: Spectrum may be strongly'',
     1        '' biased'',/15X,''when interaction forcing is used!'')')
          ENDIF
          KBDE(KB)=NDEDEF
          NDBOD=NDBOD+1
        ENDIF
   47   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 47
        IF(KWORD.EQ.KWEDET) GO TO 43
        IF(KWORD.EQ.KWEBOD) GO TO 46
      ENDIF
C
      IF(NDEDEF.GT.0) THEN
        IF(NDBOD.EQ.0) THEN
          WRITE(26,*) 'This detector has no active bodies.'
          STOP 'This detector has no active bodies.'
        ENDIF
      ENDIF
C
C  ************  Dose distribution.
C
      LDOSEM=.FALSE.
      IF(KWORD.EQ.KGRDXX) THEN
        LDOSEM=.TRUE.
        WRITE(26,1700)
 1700   FORMAT(/3X,72('-'),/3X,'>>>>>>  3D Dose distribution.')
        READ(BUFFER,*) DXL(1),DXU(1)
        IF(DXL(1).GT.DXU(1)) THEN
          SAVE=DXL(1)
          DXL(1)=DXU(1)
          DXU(1)=SAVE
        ENDIF
        IF(DXU(1).LT.DXL(1)+1.0D-6) THEN
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'XU must be greater than XL+1.0E-6.'
          STOP 'XU must be greater than XL+1.0E-6.'
        ENDIF
        WRITE(26,1710) DXL(1),DXU(1)
 1710   FORMAT(3X,'Dose-map box:  XL = ',1P,E13.6,' cm,  XU = ',
     1    E13.6,' cm')
   71   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 71
        IF(KWORD.EQ.KGRDYY) THEN
          READ(BUFFER,*) DXL(2),DXU(2)
          IF(DXL(2).GT.DXU(2)) THEN
            SAVE=DXL(2)
            DXL(2)=DXU(2)
            DXU(2)=SAVE
          ENDIF
          IF(DXU(2).LT.DXL(2)+1.0D-6) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'YU must be greater than YL+1.0E-6.'
            STOP 'YU must be greater than YL+1.0E-6.'
          ENDIF
          WRITE(26,1711) DXL(2),DXU(2)
 1711     FORMAT(18X,'YL = ',1P,E13.6,' cm,  YU = ',E13.6,' cm')
        ELSE
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Unrecognized keyword.'
          STOP 'Unrecognized keyword.'
        ENDIF
   72   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 72
        IF(KWORD.EQ.KGRDZZ) THEN
          READ(BUFFER,*) DXL(3),DXU(3)
          IF(DXL(3).GT.DXU(3)) THEN
            SAVE=DXL(3)
            DXL(3)=DXU(3)
            DXU(3)=SAVE
          ENDIF
          IF(DXU(3).LT.DXL(3)+1.0D-6) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,*) 'ZU must be greater than ZL+1.0E-6.'
            STOP 'ZU must be greater than ZL+1.0E-6.'
          ENDIF
          WRITE(26,1712) DXL(3),DXU(3)
 1712     FORMAT(18X,'ZL = ',1P,E13.6,' cm,  ZU = ',E13.6,' cm')
        ELSE
          WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
          WRITE(26,*) 'Unrecognized keyword.'
          STOP 'Unrecognized keyword.'
        ENDIF
   73   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 73
        IF(KWORD.EQ.KGRDBN) THEN
          READ(BUFFER,*) NDBX,NDBY,NDBZ
          IF(NDBX.LT.0.OR.NDBX.GT.NDXM) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,'(''NDBX must be .GT.0. and .LT.'',I4)') NDXM
            WRITE(26,*) 'Increase the value of the parameter NDXM.'
            STOP 'NDBX must be .GT.0. and .LE.NDXM'
          ENDIF
          IF(NDBY.LT.0.OR.NDBY.GT.NDYM) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,'(''NDBY must be .GT.0. and .LT.'',I4)') NDYM
            WRITE(26,*) 'Increase the value of the parameter NDYM.'
            STOP 'NDBY must be .GT.0. and .LE.NDYM'
          ENDIF
          IF(NDBZ.LT.0.OR.NDBZ.GT.NDZM) THEN
            WRITE(26,'(A6,1X,A120)') KWORD,BUFFER
            WRITE(26,'(''NDBZ must be .GT.0. and .LT.'',I4)') NDZM
            WRITE(26,*) 'Increase the value of the parameter NDZM.'
            STOP 'NDBZ must be .GT.0. and .LE.NDZM'
          ENDIF
          NDB(1)=NDBX
          NDB(2)=NDBY
          NDB(3)=NDBZ
        ELSE
          NDB(1)=25
          NDB(2)=25
          NDB(3)=25
        ENDIF
        WRITE(26,1713) NDB(1),NDB(2),NDB(3)
 1713   FORMAT(3X,'Numbers of bins:   NDBX =',I4,', NDBY =',I4,
     1    ', NDBZ =',I4)
        DO I=1,3
          BDOSE(I)=FSAFE*(DXU(I)-DXL(I))/DBLE(NDB(I))
          RBDOSE(I)=1.0D0/BDOSE(I)
        ENDDO
   74   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 74
      ENDIF
C
C  ************  Job characteristics.
C
      WRITE(26,1800)
 1800 FORMAT(/3X,72('-'),/
     1  3X,'>>>>>>  Job characteristics.')
C
      IRESUM=0
      IF(KWORD.EQ.KWRESU) THEN
        READ(BUFFER,'(A20)') PFILER
        WRITE(26,1810) PFILER
 1810   FORMAT(3X,'Resume simulation from previous dump file: ',A20)
        IRESUM=1
   75   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 75
      ENDIF
C
      DUMPP=1.0D15
      IF(KWORD.EQ.KWDUMP) THEN
        READ(BUFFER,'(A20)') PFILED
        WRITE(26,1820) PFILED
 1820   FORMAT(3X,'Write final counter values on the dump file: ',A20)
        LDUMP=.TRUE.
   76   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 76
      ENDIF
C
      IF(KWORD.EQ.KWDMPP) THEN
        READ(BUFFER,*) DUMPP
        IF(LDUMP) THEN
          IF(DUMPP.LT.15.0D0) DUMPP=15.0D0
          IF(DUMPP.GT.86400.0D0) DUMPP=86400.0D0
          WRITE(26,1830) DUMPP
 1830     FORMAT(3X,'Dumping period: DUMPP =',1P,E13.6)
        ENDIF
   77   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 77
      ENDIF
C
      IF(KWORD.EQ.KWRSEE) THEN
        READ(BUFFER,*) ISEED1,ISEED2
   79   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 79
      ELSE
        ISEED1=1
        ISEED2=1
      ENDIF
      WRITE(26,1850) ISEED1,ISEED2
 1850 FORMAT(3X,'Random-number generator seeds = ',I10,', ',I10)
C
      IF(KWORD.EQ.KWNSIM) THEN
        READ(BUFFER,*) DSHN
        IF(DSHN.LT.1.0D0) DSHN=2.0D9
   78   CONTINUE
        READ(5,'(A6,1X,A120)') KWORD,BUFFER
        IF(KWORD.EQ.KWCOMM) GO TO 78
      ELSE
        DSHN=2.0D9
      ENDIF
      WRITE(26,1840) DSHN
 1840 FORMAT(/3X,'Number of showers to be simulated =',1P,E13.6)
C
      IF(KWORD.EQ.KWTIME) THEN
        READ(BUFFER,*) TIMEA
      ELSE
        TIMEA=2.0D9
      ENDIF
      IF(TIMEA.LT.1.0D0) TIMEA=100.0D0
      WRITE(26,1860) TIMEA
 1860 FORMAT(3X,'Computation time available = ',1P,E13.6,' sec')
C
      CALL TIMER(TSECIN)
      TSECA=TIMEA+TSECIN
      TSECAD=TSECIN
      WRITE(26,1870)
 1870 FORMAT(/3X,72('-'))
C
C  ************  If 'RESUME' is active, read previously generated
C                counters...
C
      SHNA=0.0D0
      CPUTA=0.0D0
      N=0
C
      RLAST=0.0D0
      RWRITE=0.0D0
C
      IF(IRESUM.EQ.1) THEN
        WRITE(6,*) '  Reading the DUMP file ...'
        OPEN(9,FILE=PFILER)
        READ (9,*,ERR=91,END=91) SHNA,CPUTA
        READ (9,'(A65)',ERR=90) TITLE2
        IF(TITLE2.NE.TITLE) THEN
          WRITE(26,*)
     1      'The dump file is corrupted (the TITLE does not match).'
          STOP 'The dump file is corrupted (the TITLE does not match).'
        ENDIF
        READ (9,*,ERR=90) ISEED1,ISEED2
        READ (9,*,ERR=90) NPSN,RLREAD
        READ (9,*,ERR=90) (SHIST(I),I=1,NSEB)
        READ (9,*,ERR=90) (PRIM(I),I=1,3),(PRIM2(I),I=1,3)
        READ (9,*,ERR=90) ((SEC(K,I),I=1,3),K=1,3),
     1             ((SEC2(K,I),I=1,3),K=1,3)
        READ (9,*,ERR=90) (TDEBO(I),I=1,NBODY), (TDEBO2(I),I=1,NBODY)
        READ (9,*,ERR=90) (((PDE(I,J,K),K=1,NBE),J=1,2),I=1,3),
     1             (((PDE2(I,J,K),K=1,NBE),J=1,2),I=1,3)
        READ (9,*,ERR=90) (((PDA(I,J,K),K=1,NBPH),J=1,NBTH),I=1,3),
     1             (((PDA2(I,J,K),K=1,NBPH),J=1,NBTH),I=1,3)
        READ (9,*,ERR=90) (TDID(I),I=1,NIDM), (TDID2(I),I=1,NIDM)
        READ (9,*,ERR=90) (TDED(I),I=1,NEDM), (TDED2(I),I=1,NEDM)
        IF(NDIDEF.GT.0) THEN
          READ (9,*,ERR=90) RLAST,RWRITE
          DO ID=1,NDIDEF
            READ (9,*,ERR=90) (DIT(ID,J),J=1,NDICH(ID))
            READ (9,*,ERR=90) (DIT2(ID,J),J=1,NDICH(ID))
            READ (9,*,ERR=90) ((DIP(ID,J,K),J=1,NDICH(ID)),K=1,3)
            READ (9,*,ERR=90) ((DIP2(ID,J,K),J=1,NDICH(ID)),K=1,3)
            IF(IDCUT(ID).EQ.2) THEN
              READ (9,*,ERR=90) (FST(ID,J),J=1,NDICH(ID))
              READ (9,*,ERR=90) (FST2(ID,J),J=1,NDICH(ID))
              READ (9,*,ERR=90) ((FSP(ID,J,K),J=1,NDICH(ID)),K=1,3)
              READ (9,*,ERR=90) ((FSP2(ID,J,K),J=1,NDICH(ID)),K=1,3)
            ENDIF
          ENDDO
        ENDIF
        IF(NDEDEF.GT.0) THEN
          DO ID=1,NDEDEF
            READ (9,*,ERR=90) (DET(ID,J),J=1,NDECH(ID))
          ENDDO
        ENDIF
        IF(LDOSEM) THEN
          READ (9,*,ERR=90)
     1      (((DOSE(I1,I2,I3),I3=1,NDB(3)),I2=1,NDB(2)),I1=1,NDB(1)),
     1      (((DOSE2(I1,I2,I3),I3=1,NDB(3)),I2=1,NDB(2)),I1=1,NDB(1))
          READ (9,*,ERR=90)
     1      (DDOSE(I3),I3=1,NDB(3)),(DDOSE2(I3),I3=1,NDB(3))
        ENDIF
        CLOSE(9)
        WRITE(26,1880) PFILER
 1880   FORMAT(3X,'Simulation has been resumed from dump file: ',A20)
        GO TO 92
   90   CONTINUE
        WRITE(26,*) 'The dump file is empty or corrupted.'
        STOP 'The dump file is empty or corrupted.'
   91   CONTINUE
        WRITE(26,1890)
 1890   FORMAT(3X,'WARNING: Could not resume from dump file...')
        CLOSE(9)
        IRESUM=0
      ENDIF
   92 CONTINUE
C
      IPSFO=21
      IF(NDIDEF.GT.0) THEN
        DO ID=1,NDIDEF
          IF(IPSF(ID).GT.0) THEN
            OPEN(IPSFO,FILE=PSFDIO(ID),IOSTAT=KODE)
            IF(KODE.NE.0) THEN
              WRITE(26,'(''File '',A20,'' could not be opened.'')')
     1          PSFDIO(ID)
              STOP 'File could not be opened.'
            ENDIF
            RWR=0.0D0
            IF(RWRITE.GT.0) THEN
   93         CONTINUE
              KODEPS=0
              CALL RDPSF(IPSFO,NSHI,ISEC,KODEPS)
              IF(KODEPS.EQ.-1) THEN
                GO TO 94
              ELSE
                RWR=RWR+1.0D0
                IF(RWR.LT.RWRITE-0.5D0) GO TO 93
                GO TO 94
              ENDIF
            ENDIF
   94       CONTINUE
            IF(RWR.LT.0.5D0) THEN
              WRITE(IPSFO,1901) ID
 1901         FORMAT(1X,'#  Results from PENMAIN. Phase-space fi',
     1          'le of detector no.',I3,/1X,'#')
              WRITE(IPSFO,1902)
 1902         FORMAT(1X,'#/KPAR',2X,'E',12X,'X',12X,'Y',12X,'Z',12X,
     1          'U',12X,'V',12X,'W',11X,'WGHT',5X,'ILB(1:4)',7X,'NSHI',
     1          /1X,'#',125('-'))
            ENDIF
          ENDIF
        ENDDO
      ENDIF
C
      IPSFI=20
      IF(LPSF) THEN
        IF(IRESUM.EQ.1) THEN
          IF(NPSN.GT.NPSF) THEN
            WRITE(6,*) '  **** The simulation was already completed.'
            WRITE(26,*) '  **** The simulation was already completed.'
            SHN=SHNA
            TSIM=CPUTA
            CPUT0=CPUTIM()
            JOBEND=1
            RETURN
          ENDIF
          IF(NPSN.GT.1) THEN
            DO I=1,NPSN-1
              WRITE(6,1903) PSFI(I)
              WRITE(26,1903) PSFI(I)
 1903         FORMAT(/3X,'+ The phase-space file ',A20,
     1          ' was read in previous runs.')
            ENDDO
          ENDIF
   95     CONTINUE
          OPEN(IPSFI,FILE=PSFI(NPSN))
          KODEPS=0
          CALL RDPSF(IPSFI,NSHI,ISEC,KODEPS)
          WRITE(6,1904) PSFI(NPSN)
          WRITE(26,1904) PSFI(NPSN)
 1904     FORMAT(/3X,'+ The phase-space file ',A20,' is opened.')
          IF(KODEPS.EQ.-1) THEN
            WRITE(26,*) ' STOP. The file is empty or corrupted.'
            STOP 'The file is empty or corrupted.'
          ENDIF
          IF(RLREAD.GT.0.5D0) THEN
            RI=0.0D0
   96       CONTINUE
            RI=RI+1.0D0
            CALL RDPSF(IPSFI,NSHI,ISEC,KODEPS)
            IF(KODEPS.EQ.-1) THEN
              NPSN=NPSN+1
              IF(NPSN.GT.NPSF) THEN
                WRITE(6,*)
     1            '  **** The simulation was already completed.'
                WRITE(26,*)
     1            '  **** The simulation was already completed.'
                SHN=SHNA
                TSIM=CPUTA
                CPUT0=CPUTIM()
                JOBEND=2
                RETURN
              ELSE
                WRITE(6,1905) PSFI(NPSN)
                WRITE(26,1905) PSFI(NPSN)
 1905           FORMAT(/3X,'+ The phase-space file ',A20,
     1            ' was completed in the last run.')
                CLOSE(IPSFI)
                RLREAD=0.0D0
                GO TO 95
              ENDIF
            ENDIF
            IF(RI.LT.RLREAD-0.5D0) GO TO 96
          ELSE
            RLREAD=0.0D0
          ENDIF
        ELSE
          NPSN=1
          RLREAD=0.0D0
          WRITE(6,1904) PSFI(NPSN)
          WRITE(26,1904) PSFI(NPSN)
          OPEN(IPSFI,FILE=PSFI(NPSN),IOSTAT=KODE)
          IF(KODE.NE.0) THEN
            WRITE(26,'(''File '',A20,'' could not be opened.'')')
     1        PSFI(NPSN)
            STOP 'File could not be opened.'
          ENDIF
          KODEPS=0
          CALL RDPSF(IPSFI,NSHI,ISEC,KODEPS)
          IF(KODEPS.EQ.-1) THEN
            WRITE(26,*) ' STOP. The file is empty or corrupted.'
            STOP 'The file is empty or corrupted.'
          ENDIF
        ENDIF
      ENDIF
C
C  ************  Initialise constants.
C
      SHN=SHNA  ! Shower counter, particles from the dump file.
      N=MOD(SHN,2.0D9)+0.5D0
      TSIM=CPUTA
      CPUT0=CPUTIM()
      IF(SHN.GT.DSHN-0.5D0) THEN
        WRITE(6,*) '  **** The simulation was already completed.'
        WRITE(26,*) '  **** The simulation was already completed.'
        JOBEND=3
      ELSE
        WRITE(6,*) '  The simulation is started ...'
      ENDIF
C
      RETURN
      END
C  *********************************************************************
C                       SUBROUTINE SHOWER
C  *********************************************************************
      SUBROUTINE SHOWER
C
C  Simulates a new shower and keeps score of relevant quantities.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      LOGICAL LINTF
      INCLUDE 'pmcomms.f'
      EXTERNAL RAND
C
C  ------------------------  Shower simulation starts here.
C
C  ************  Primary particle counters.
C
  101 CONTINUE
c     write(6,*) ISEED1,ISEED2
      DO I=1,3
        DPRIM(I)=0.0D0
        DO K=1,3
          DSEC(K,I)=0.0D0
        ENDDO
      ENDDO
C
      DO KB=1,NBODY
        DEBO(KB)=0.0D0  ! Energies deposited in the various bodies KB.
      ENDDO
C
      IF(NDIDEF.GT.0) THEN
        DO KD=1,NDIDEF
          DEDI(KD)=0.0D0  ! Energy collected by each detector.
        ENDDO
      ENDIF
      IEXIT=0
C
      CALL CLEANS          ! Cleans the secondary stack.
C
C  **********  Set the initial state of the primary particle.
C
  201 CONTINUE
      IF(KPARP.EQ.0) THEN
C  ****  User-defined source.
        CALL SOURCE
        SHN=SHN+1.0D0
        N=N+1
        IF(N.GT.2000000000) N=N-2000000000
        IF(LSPEC) THEN
          KE=E*RDSHE+1.0D0
          SHIST(KE)=SHIST(KE)+1.0D0
        ENDIF
c     write(6,'(''n,kpar,gen,x,y,z,w,e,ibody='',3i3,1p,5e11.3,0p,i3)')
c    1    MOD(N,100),KPAR,ILB(1),X,Y,Z,W,E,IBODY
      ELSE IF(LPSF) THEN
C  ****  Phase-space file.
        CALL RDPSF(IPSFI,NSHI,ISEC,KODEPS)
        IF(KODEPS.EQ.-1) THEN
c       write(35,'(i2,1p,8e13.5,i3,i2,i2,i9,i9,2i3)')
c    1    KPAR,E,X,Y,Z,U,V,W,WGHT,ILB(1),ILB(2),ILB(3),ILB(4),
c    2    NSHI,ISEC,KODEPS
          CLOSE(IPSFI)
          NPSN=NPSN+1
          RLREAD=0.0D0
          IF(NPSN.GT.NPSF) THEN
            JOBEND=4
            RETURN
          ENDIF
          OPEN(IPSFI,FILE=PSFI(NPSN))
          WRITE(6,3040) SHN
          WRITE(6,1904) PSFI(NPSN)
          WRITE(26,1904) PSFI(NPSN)
          KODEPS=0
          CALL RDPSF(IPSFI,NSHI,ISEC,KODEPS)
c       write(35,'(i2,1p,8e13.5,i3,i2,i2,i9,i9,2i3)')
c    1    KPAR,E,X,Y,Z,U,V,W,WGHT,ILB(1),ILB(2),ILB(3),ILB(4),
c    2    NSHI,ISEC,KODEPS
          GO TO 101
        ENDIF
 3040   FORMAT(2X,'Number of simulated showers =',1P,E14.7)
 1904   FORMAT(/3X,'+ The phase-space file ',A20,' is opened.')
C
        RLREAD=RLREAD+1.0D0
        SHN=SHN+DBLE(NSHI)
        N=N+NSHI
        IF(N.GT.2000000000) N=N-2000000000
        ILB(5)=0
        IPOL=0  ! Particles in the phase-space file are unpolarized.
      ELSE
C  ****  External source.
        SHN=SHN+1.0D0
        N=N+1
        IF(N.GT.2000000000) N=N-2000000000
        KPAR=KPARP
        WGHT=1.0D0
C  ----  Initial position ...
        IF(LEXSRC) THEN
          IF(LEXBD) THEN
            NTRIAL=0
  301       CONTINUE
            X=SX0+(RAND(1.0D0)-0.5D0)*SSX
            Y=SY0+(RAND(2.0D0)-0.5D0)*SSY
            Z=SZ0+(RAND(3.0D0)-0.5D0)*SSZ
            CALL LOCATE
            NTRIAL=NTRIAL+1
            IF(NTRIAL.GT.200) THEN
              WRITE(26,'(3X,''WARNING: the sampling of initial '',
     1          ''positions may be very inefficient.'')')
              WRITE(6,'(3X,''WARNING: the sampling of initial '',
     1          ''positions may be very inefficient.'')')
            ENDIF
            IF(IXSBOD(IBODY).EQ.0) GO TO 301
          ELSE
            X=SX0+(RAND(1.0D0)-0.5D0)*SSX
            Y=SY0+(RAND(2.0D0)-0.5D0)*SSY
            Z=SZ0+(RAND(3.0D0)-0.5D0)*SSZ
          ENDIF
        ELSE
          X=SX0
          Y=SY0
          Z=SZ0
        ENDIF
C  ----  Initial direction ...
        IF(LSCONE) THEN
          CALL GCONE(U,V,W)  ! Conical beam.
        ELSE
          W=CTHL+RAND(4.0D0)*DCTH  ! Rectangular beam.
          UV=SQRT(1.0D0-W*W)
          PHI=PHIL+RAND(5.0D0)*DPHI
          U=UV*COS(PHI)
          V=UV*SIN(PHI)
        ENDIF
C  ----  Initial energy ...
        IF(LSPEC) THEN
          RN=RAND(6.0D0)*NSEB+1
          K=INT(RN) ! Continuous spectrum. E sampled by Walker's method.
          RNF=RN-K
          IF(RNF.GT.FS(K)) THEN
            KE=IAS(K)
          ELSE
            KE=K
          ENDIF
          E=ES(KE)+RAND(7.0D0)*(ES(KE+1)-ES(KE))
          SHIST(KE)=SHIST(KE)+1.0D0
        ELSE
          E=E0      ! Monoenergetic source.
          SHIST(1)=SHIST(1)+1.0D0
        ENDIF
        ILB(1)=1  ! Identifies primary particles.
        ILB(2)=0
        ILB(3)=0
        ILB(4)=0
        ILB(5)=0
        IF(KPAR.EQ.2) THEN
          IF(LGPOL) THEN
            IPOL=1  ! Photon polarisation.
            SP1=SP10
            SP2=SP20
            SP3=SP30
          ELSE
            IPOL=0
          ENDIF
        ELSE
          IPOL=0
        ENDIF
      ENDIF
C
C  ****  Check if the trajectory intersects the material system.
C
  302 CONTINUE
      CALL LOCATE
C
      IF(MAT.EQ.0) THEN
        IBODYL=IBODY
        CALL STEP(1.0D30,DSEF,NCROSS)
        IF(MAT.EQ.0) THEN  ! The particle does not enter the system.
          IF(W.GT.0) THEN
            IEXIT=1        ! Labels emerging upbound particles.
          ELSE
            IEXIT=2        ! Labels emerging downbound particles.
          ENDIF
          GO TO 104        ! Exit.
        ENDIF

C  ----  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
C  ----  Impact detectors.
        IDET=KDET(IBODY)
        IF(IDET.NE.0) THEN
          IF(KDET(IBODYL).NE.IDET.AND.KKDI(IDET,KPAR).EQ.1) THEN
C
            IF(IPSF(IDET).EQ.1) THEN
              NSHJ=SHN-RLAST
              CALL WRPSF(IPSFO,NSHJ,0)
              RWRITE=RWRITE+1.0D0
              RLAST=SHN
            ENDIF
C
            DEDI(IDET)=DEDI(IDET)+E*WGHT
            IF(LDILOG(IDET)) THEN
              IE=1.0D0+(LOG(E)-EDILL(IDET))*RBDIEL(IDET)
            ELSE
              IE=1.0D0+(E-EDIL(IDET))*RBDIE(IDET)
            ENDIF
            IF(IE.GT.0.AND.IE.LE.NDICH(IDET)) THEN
              IF(N.NE.LDIT(IDET,IE)) THEN
                DIT(IDET,IE)=DIT(IDET,IE)+DITP(IDET,IE)
                DIT2(IDET,IE)=DIT2(IDET,IE)+DITP(IDET,IE)**2
                DITP(IDET,IE)=WGHT
                LDIT(IDET,IE)=N
              ELSE
                DITP(IDET,IE)=DITP(IDET,IE)+WGHT
              ENDIF
              IF(N.NE.LDIP(IDET,IE,KPAR)) THEN
                DIP(IDET,IE,KPAR)=DIP(IDET,IE,KPAR)+DIPP(IDET,IE,KPAR)
                DIP2(IDET,IE,KPAR)=
     1              DIP2(IDET,IE,KPAR)+DIPP(IDET,IE,KPAR)**2
                DIPP(IDET,IE,KPAR)=WGHT
                LDIP(IDET,IE,KPAR)=N
              ELSE
                DIPP(IDET,IE,KPAR)=DIPP(IDET,IE,KPAR)+WGHT
              ENDIF
            ENDIF
            IF(IDCUT(IDET).EQ.0) THEN
              DEBO(IBODY)=DEBO(IBODY)+E*WGHT
              IEXIT=3
              GO TO 104
            ENDIF
          ENDIF
        ENDIF
C  ----  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

      ENDIF
C
      IF(E.LT.EABSB(KPAR,IBODY)) THEN  ! The energy is too low.
        DEP=E*WGHT
        DEBO(IBODY)=DEBO(IBODY)+DEP
        IF(LDOSEM) THEN  ! Particle inside the dose box.
          IF((X.GT.DXL(1).AND.X.LT.DXU(1)).AND.
     1       (Y.GT.DXL(2).AND.Y.LT.DXU(2)).AND.
     1       (Z.GT.DXL(3).AND.Z.LT.DXU(3))) THEN
            I1=1.0D0+(X-DXL(1))*RBDOSE(1)
            I2=1.0D0+(Y-DXL(2))*RBDOSE(2)
            I3=1.0D0+(Z-DXL(3))*RBDOSE(3)
            DOSP=DEP*RHOI(MAT)
            IF(N.NE.LDOSE(I1,I2,I3)) THEN
              DOSE(I1,I2,I3)=DOSE(I1,I2,I3)+DOSEP(I1,I2,I3)
              DOSE2(I1,I2,I3)=DOSE2(I1,I2,I3)+DOSEP(I1,I2,I3)**2
              DOSEP(I1,I2,I3)=DOSP
              LDOSE(I1,I2,I3)=N
            ELSE
              DOSEP(I1,I2,I3)=DOSEP(I1,I2,I3)+DOSP
            ENDIF
C
            IF(N.NE.LDDOSE(I3)) THEN
              DDOSE(I3)=DDOSE(I3)+DDOSEP(I3)
              DDOSE2(I3)=DDOSE2(I3)+DDOSEP(I3)**2
              DDOSEP(I3)=DOSP
              LDDOSE(I3)=N
            ELSE
              DDOSEP(I3)=DDOSEP(I3)+DOSP
            ENDIF
          ENDIF
        ENDIF
        IEXIT=3
        GO TO 104
      ENDIF
C  ---------------------------------------------------------------------
C  ------------------------  Track simulation begins here.
C

C  >>>>>>>>>>>>  Particle splitting and Russian roulette  >>>>>>>>>>>>>>
C  ...  only for particles read from phase-space files.
      IF(LPSF) THEN
C  ----  Russian roulette (weight window).
        IF(WGHT.LT.WGMIN) THEN
          PKILL=1.0D0-WGHT*RWGMIN
          CALL VKILL(PKILL)
          IF(E.LT.1.0D0) GO TO 201
        ENDIF
C  ----  Splitting.
        NSPL1=MAX(MIN(NSPLIT,INT(MIN(1.0D5,WGHT*RWGMIN))),1)
        IF(NSPL1.GT.1) THEN
          CALL VSPLIT(NSPL1)
C  ----  Energy is locally deposited in the material.
          DEP=(NSPL1-1)*E*WGHT
          DEBO(IBODY)=DEBO(IBODY)+DEP
          IF(LDOSEM) THEN  ! Particle inside the dose box.
            IF((X.GT.DXL(1).AND.X.LT.DXU(1)).AND.
     1         (Y.GT.DXL(2).AND.Y.LT.DXU(2)).AND.
     1         (Z.GT.DXL(3).AND.Z.LT.DXU(3))) THEN
              I1=1.0D0+(X-DXL(1))*RBDOSE(1)
              I2=1.0D0+(Y-DXL(2))*RBDOSE(2)
              I3=1.0D0+(Z-DXL(3))*RBDOSE(3)
              DOSP=DEP*RHOI(MAT)
              IF(N.NE.LDOSE(I1,I2,I3)) THEN
                DOSE(I1,I2,I3)=DOSE(I1,I2,I3)+DOSEP(I1,I2,I3)
                DOSE2(I1,I2,I3)=DOSE2(I1,I2,I3)+DOSEP(I1,I2,I3)**2
                DOSEP(I1,I2,I3)=DOSP
                LDOSE(I1,I2,I3)=N
              ELSE
                DOSEP(I1,I2,I3)=DOSEP(I1,I2,I3)+DOSP
              ENDIF
C
              IF(N.NE.LDDOSE(I3)) THEN
                DDOSE(I3)=DDOSE(I3)+DDOSEP(I3)
                DDOSE2(I3)=DDOSE2(I3)+DDOSEP(I3)**2
                DDOSEP(I3)=DOSP
                LDDOSE(I3)=N
              ELSE
                DDOSEP(I3)=DDOSEP(I3)+DOSP
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDIF
C  <<<<<<<<<<<<  Particle splitting and Russian roulette  <<<<<<<<<<<<<<

  102 CONTINUE
      EABS(KPAR,MAT)=EABSB(KPAR,IBODY)
C
C  ************  The particle energy is less than EABS.
C
      IF(E.LT.EABS(KPAR,MAT)) THEN  ! The particle is absorbed.
        DEP=E*WGHT
C  ----  Energy is locally deposited in the material.
        DEBO(IBODY)=DEBO(IBODY)+DEP
        IF(LDOSEM) THEN  ! Particle inside the dose box.
          IF((X.GT.DXL(1).AND.X.LT.DXU(1)).AND.
     1       (Y.GT.DXL(2).AND.Y.LT.DXU(2)).AND.
     1       (Z.GT.DXL(3).AND.Z.LT.DXU(3))) THEN
            I1=1.0D0+(X-DXL(1))*RBDOSE(1)
            I2=1.0D0+(Y-DXL(2))*RBDOSE(2)
            I3=1.0D0+(Z-DXL(3))*RBDOSE(3)
            DOSP=DEP*RHOI(MAT)
            IF(N.NE.LDOSE(I1,I2,I3)) THEN
              DOSE(I1,I2,I3)=DOSE(I1,I2,I3)+DOSEP(I1,I2,I3)
              DOSE2(I1,I2,I3)=DOSE2(I1,I2,I3)+DOSEP(I1,I2,I3)**2
              DOSEP(I1,I2,I3)=DOSP
              LDOSE(I1,I2,I3)=N
            ELSE
              DOSEP(I1,I2,I3)=DOSEP(I1,I2,I3)+DOSP
            ENDIF
C
            IF(N.NE.LDDOSE(I3)) THEN
              DDOSE(I3)=DDOSE(I3)+DDOSEP(I3)
              DDOSE2(I3)=DDOSE2(I3)+DDOSEP(I3)**2
              DDOSEP(I3)=DOSP
              LDDOSE(I3)=N
            ELSE
              DDOSEP(I3)=DDOSEP(I3)+DOSP
            ENDIF
          ENDIF
        ENDIF
        IEXIT=3                     ! Labels absorbed particles.
        GO TO 104                   ! Exit.
      ENDIF
C
      CALL START           ! Starts simulation in current medium.
C
  103 CONTINUE
      IBODYL=IBODY
c     write(6,'(''n,kpar,gen,x,y,z,w,e,ibody='',3i3,1p,5e11.3,0p,i3)')
c    1    MOD(N,100),KPAR,ILB(1),X,Y,Z,W,E,IBODY
C
      IF(LFORCE(IBODY,KPAR).AND.((WGHT.GE.WLOW(IBODY,KPAR)).AND.
     1  (WGHT.LE.WHIG(IBODY,KPAR)))) THEN
        CALL JUMPF(DSMAX(IBODY),DS)  ! Interaction forcing.
        LINTF=.TRUE.
      ELSE
        CALL JUMP(DSMAX(IBODY),DS)   ! Analogue simulation.
        LINTF=.FALSE.
      ENDIF
      CALL STEP(DS,DSEF,NCROSS)      ! Determines step end position.

C  ----  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
C  ----  Energy distribution of fluence.
      IDET=KDET(IBODYL)
      IF(IDET.NE.0) THEN
        IF(IDCUT(IDET).EQ.2) THEN
          IF(KKDI(IDET,KPAR).EQ.1) THEN
            IF(LDILOG(IDET)) THEN
              IE=1.0D0+(LOG(E)-EDILL(IDET))*RBDIEL(IDET)
            ELSE
              IE=1.0D0+(E-EDIL(IDET))*RBDIE(IDET)
            ENDIF
            IF(IE.GT.0.AND.IE.LE.NDICH(IDET)) THEN
              IF(N.NE.LFST(IDET,IE)) THEN
                FST(IDET,IE)=FST(IDET,IE)+FSTP(IDET,IE)
                FST2(IDET,IE)=FST2(IDET,IE)+FSTP(IDET,IE)**2
                FSTP(IDET,IE)=WGHT*DSEF
                LFST(IDET,IE)=N
              ELSE
                FSTP(IDET,IE)=FSTP(IDET,IE)+WGHT*DSEF
              ENDIF
              IF(N.NE.LFSP(IDET,IE,KPAR)) THEN
                FSP(IDET,IE,KPAR)=FSP(IDET,IE,KPAR)+FSPP(IDET,IE,KPAR)
                FSP2(IDET,IE,KPAR)=
     1              FSP2(IDET,IE,KPAR)+FSPP(IDET,IE,KPAR)**2
                FSPP(IDET,IE,KPAR)=WGHT*DSEF
                LFSP(IDET,IE,KPAR)=N
              ELSE
                FSPP(IDET,IE,KPAR)=FSPP(IDET,IE,KPAR)+WGHT*DSEF
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDIF
C  ----  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

C  ----  Check whether the particle is outside the enclosure.
      IF(MAT.EQ.0) THEN
        IF(W.GT.0) THEN
          IEXIT=1        ! Labels emerging upbound particles.
        ELSE
          IEXIT=2        ! Labels emerging downbound particles.
        ENDIF
        GO TO 104        ! Exit.
      ENDIF

C  ----  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
C  ----  Impact detectors.
      IDET=KDET(IBODY)
      IF(IDET.NE.0) THEN
        IF(KDET(IBODYL).NE.IDET.AND.KKDI(IDET,KPAR).EQ.1) THEN
C
          IF(IPSF(IDET).EQ.1) THEN
            NSHJ=SHN-RLAST
            CALL WRPSF(IPSFO,NSHJ,0)
            RWRITE=RWRITE+1.0D0
            RLAST=SHN
          ENDIF
C
          DEDI(IDET)=DEDI(IDET)+E*WGHT
          IF(LDILOG(IDET)) THEN
            IE=1.0D0+(LOG(E)-EDILL(IDET))*RBDIEL(IDET)
          ELSE
            IE=1.0D0+(E-EDIL(IDET))*RBDIE(IDET)
          ENDIF
          IF(IE.GT.0.AND.IE.LE.NDICH(IDET)) THEN
            IF(N.NE.LDIT(IDET,IE)) THEN
              DIT(IDET,IE)=DIT(IDET,IE)+DITP(IDET,IE)
              DIT2(IDET,IE)=DIT2(IDET,IE)+DITP(IDET,IE)**2
              DITP(IDET,IE)=WGHT
              LDIT(IDET,IE)=N
            ELSE
              DITP(IDET,IE)=DITP(IDET,IE)+WGHT
            ENDIF
            IF(N.NE.LDIP(IDET,IE,KPAR)) THEN
              DIP(IDET,IE,KPAR)=DIP(IDET,IE,KPAR)+DIPP(IDET,IE,KPAR)
              DIP2(IDET,IE,KPAR)=
     1            DIP2(IDET,IE,KPAR)+DIPP(IDET,IE,KPAR)**2
              DIPP(IDET,IE,KPAR)=WGHT
              LDIP(IDET,IE,KPAR)=N
            ELSE
              DIPP(IDET,IE,KPAR)=DIPP(IDET,IE,KPAR)+WGHT
            ENDIF
          ENDIF
          IF(IDCUT(IDET).EQ.0) THEN
            DEBO(IBODY)=DEBO(IBODY)+E*WGHT
            IEXIT=3
            GO TO 104
          ENDIF
        ENDIF
      ENDIF
C  ----  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

C  ----  If the particle has crossed an interface, restart the track in
C        the new material.
      IF(NCROSS.GT.0) GO TO 102    ! The particle crossed an interface.
C  ----  Simulate next event.
      IF(LINTF) THEN
        CALL KNOCKF(DE,ICOL)       ! Interaction forcing is active.
      ELSE
        CALL KNOCK(DE,ICOL)        ! Analogue simulation.
      ENDIF
      DEP=DE*WGHT
C  ----  Energy is locally deposited in the material.
      DEBO(IBODY)=DEBO(IBODY)+DEP
      IF(LDOSEM) THEN  ! The particle is inside the dose box.
        IF((X.GT.DXL(1).AND.X.LT.DXU(1)).AND.
     1     (Y.GT.DXL(2).AND.Y.LT.DXU(2)).AND.
     1     (Z.GT.DXL(3).AND.Z.LT.DXU(3))) THEN
          I1=1.0D0+(X-DXL(1))*RBDOSE(1)
          I2=1.0D0+(Y-DXL(2))*RBDOSE(2)
          I3=1.0D0+(Z-DXL(3))*RBDOSE(3)
          DOSP=DEP*RHOI(MAT)
          IF(N.NE.LDOSE(I1,I2,I3)) THEN
            DOSE(I1,I2,I3)=DOSE(I1,I2,I3)+DOSEP(I1,I2,I3)
            DOSE2(I1,I2,I3)=DOSE2(I1,I2,I3)+DOSEP(I1,I2,I3)**2
            DOSEP(I1,I2,I3)=DOSP
            LDOSE(I1,I2,I3)=N
          ELSE
            DOSEP(I1,I2,I3)=DOSEP(I1,I2,I3)+DOSP
          ENDIF
C
          IF(N.NE.LDDOSE(I3)) THEN
            DDOSE(I3)=DDOSE(I3)+DDOSEP(I3)
            DDOSE2(I3)=DDOSE2(I3)+DDOSEP(I3)**2
            DDOSEP(I3)=DOSP
            LDDOSE(I3)=N
          ELSE
            DDOSEP(I3)=DDOSEP(I3)+DOSP
          ENDIF
        ENDIF
      ENDIF
C
      IF(E.LT.EABS(KPAR,MAT)) THEN  ! The particle has been absorbed.
        IEXIT=3                     ! Labels absorbed particles.
        GO TO 104                   ! Exit.
      ENDIF
C
      GO TO 103
C  ------------------------  The simulation of the track ends here.
C  ---------------------------------------------------------------------
  104 CONTINUE
C
C  ************  Increment particle counters.
C
      IF(ILB(1).EQ.1) THEN
        DPRIM(IEXIT)=DPRIM(IEXIT)+WGHT
      ELSE
        DSEC(KPAR,IEXIT)=DSEC(KPAR,IEXIT)+WGHT
      ENDIF
C
      IF(IEXIT.LT.3) THEN
C  ****  Energy distribution of emerging particles.
        K=1.0D0+(E-EMIN)*RBSE
        IF(K.GT.0.AND.K.LE.NBE) THEN
          IF(N.NE.LPDE(KPAR,IEXIT,K)) THEN
            PDE(KPAR,IEXIT,K)=PDE(KPAR,IEXIT,K)+PDEP(KPAR,IEXIT,K)
            PDE2(KPAR,IEXIT,K)=
     1        PDE2(KPAR,IEXIT,K)+PDEP(KPAR,IEXIT,K)**2
            PDEP(KPAR,IEXIT,K)=WGHT
            LPDE(KPAR,IEXIT,K)=N
          ELSE
            PDEP(KPAR,IEXIT,K)=PDEP(KPAR,IEXIT,K)+WGHT
          ENDIF
        ENDIF
C  ****  Angular distribution of emerging particles.
        THETA=ACOS(W)
        KTH=1.0D0+THETA*RA2DE*RBSTH
        IF(ABS(U).GT.1.0D-16) THEN  ! Azimuthal bin number corrected.
           PHI=ATAN2(V,U)
        ELSE IF(ABS(V).GT.1.0D-16) THEN
           PHI=ATAN2(V,U)
        ELSE
           PHI=0.0D0
        ENDIF
        IF(PHI.LT.0.0D0) PHI=TWOPI+PHI
        KPH=1.0D0+PHI*RA2DE*RBSPH
        IF(N.NE.LPDA(KPAR,KTH,KPH)) THEN
          PDA(KPAR,KTH,KPH)=PDA(KPAR,KTH,KPH)+PDAP(KPAR,KTH,KPH)
          PDA2(KPAR,KTH,KPH)=PDA2(KPAR,KTH,KPH)+PDAP(KPAR,KTH,KPH)**2
          PDAP(KPAR,KTH,KPH)=WGHT
          LPDA(KPAR,KTH,KPH)=N
        ELSE
          PDAP(KPAR,KTH,KPH)=PDAP(KPAR,KTH,KPH)+WGHT
        ENDIF
      ENDIF
C
C  ************  Any secondary left?
C
  202 CONTINUE
      CALL SECPAR(LEFT)
      IF(LEFT.GT.0) THEN
c     write(6,'(/''new secondary'')')
c     write(6,'(''n,kpar,ilb(1:4),ibody,mat='',i6,4i4,i10,2i4)')
c    1    N,KPAR,ILB(1),ILB(2),ILB(3),ILB(4),IBODY,MAT
c     write(6,'(''  ener,x,y,z='',1p,5e14.6)') E,X,Y,Z
c     write(6,'(''  wght,u,v,w='',1p,5e14.6)') WGHT,U,V,W
        IF(ILB(1).EQ.-1) THEN  ! Primary particle from SOURCE.
          ILB(1)=1  ! Energy is not removed from the site.
          IF(LSPEC) THEN
            KE=E*RDSHE+1.0D0
            SHIST(KE)=SHIST(KE)+1.0D0
          ENDIF
          GO TO 302
        ENDIF
        IF(E.GT.EABSB(KPAR,IBODY)) THEN
          DEBO(IBODY)=DEBO(IBODY)-E*WGHT  ! Energy is removed.
          IF(LDOSEM) THEN  ! Particle inside the dose box.
            IF((X.GT.DXL(1).AND.X.LT.DXU(1)).AND.
     1         (Y.GT.DXL(2).AND.Y.LT.DXU(2)).AND.
     1         (Z.GT.DXL(3).AND.Z.LT.DXU(3))) THEN
              I1=1.0D0+(X-DXL(1))*RBDOSE(1)
              I2=1.0D0+(Y-DXL(2))*RBDOSE(2)
              I3=1.0D0+(Z-DXL(3))*RBDOSE(3)
              DOSP=E*WGHT*RHOI(MAT)
              DOSEP(I1,I2,I3)=DOSEP(I1,I2,I3)-DOSP
              DDOSEP(I3)=DDOSEP(I3)-DOSP
            ENDIF
          ENDIF
        ELSE
          GO TO 202
        ENDIF

C  >>>>>>>>>>>>>>>>>>>>>>>  Russian roulette  >>>>>>>>>>>>>>>>>>>>>>>>>>
C  ****  Russian roulette for photons moving downstream.
cr      IF(KPAR.EQ.2.AND.W.LT.0.0D0) THEN
cr        IF(WGHT.LT.0.1D0) THEN
cr          PKILL=0.75D0
cr          CALL VKILL(PKILL)
cr          IF(E.LT.EABSB(KPAR,IBODY)) GO TO 202
cr        ENDIF
cr      ENDIF
C  <<<<<<<<<<<<<<<<<<<<<<<  Russian roulette  <<<<<<<<<<<<<<<<<<<<<<<<<<

        GO TO 102
      ENDIF
C
      IF(LPSF) THEN
        IF(ISEC.EQ.1) GO TO 201
      ENDIF
C
C  ----  Energies deposited in different bodies and detectors.
C
C  ----  Tallying the spectra from energy-deposition detectors.
      IF(NDEDEF.GT.0) THEN
        DO KD=1,NDEDEF
          DEDE(KD)=0.0D0
        ENDDO
        DO KB=1,NBODY
          IDET=KBDE(KB)
          IF(IDET.NE.0) THEN
            DEDE(IDET)=DEDE(IDET)+DEBO(KB)
          ENDIF
        ENDDO
C
        DO KD=1,NDEDEF
          TDED(KD)=TDED(KD)+DEDE(KD)
          TDED2(KD)=TDED2(KD)+DEDE(KD)**2
          IF(DEDE(KD).GT.1.0D-5) THEN
            IF(LDELOG(KD)) THEN
              KE=1.0D0+(LOG(DEDE(KD))-EDELL(KD))*RBDEEL(KD)
            ELSE
              KE=1.0D0+(DEDE(KD)-EDEL(KD))*RBDEE(KD)
            ENDIF
            IF(KE.GT.0.AND.KE.LE.NDECH(KD)) THEN
              DET(KD,KE)=DET(KD,KE)+1.0D0
            ENDIF
          ENDIF
        ENDDO
      ENDIF
      DO KB=1,NBODY
        TDEBO(KB)=TDEBO(KB)+DEBO(KB)
        TDEBO2(KB)=TDEBO2(KB)+DEBO(KB)**2
      ENDDO
C  --  Average energies 'collected' by impact detectors.
      IF(NDIDEF.GT.0) THEN
        DO KD=1,NDIDEF
          TDID(KD)=TDID(KD)+DEDI(KD)
          TDID2(KD)=TDID2(KD)+DEDI(KD)**2
        ENDDO
      ENDIF
C  --  Final state counters.
      DO I=1,3
        PRIM(I)=PRIM(I)+DPRIM(I)
        PRIM2(I)=PRIM2(I)+DPRIM(I)**2
        DO K=1,3
          SEC(K,I)=SEC(K,I)+DSEC(K,I)
          SEC2(K,I)=SEC2(K,I)+DSEC(K,I)**2
        ENDDO
      ENDDO
C
C  ------------------------  The simulation of the shower ends here.
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      RETURN
      END
C  *********************************************************************
C                       SUBROUTINE PMWRT
C  *********************************************************************
      SUBROUTINE PMWRT(ICLOSE)
C
C  Computes averages and writes results in output files.
C
C  ICLOSE is a closing flag, which is used only when the phase-space
C  file of an impact detector is being generated.
C  -- When ICLOSE .GT. 0, particles remaining in the buffer are
C     transferred to the psf, and the psf output unit is closed.
C  -- If ICLOSE .LT. 0, particles are moved to the psf, but the psf
C     output unit remains open.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      INCLUDE 'pmcomms.f'
      DIMENSION WSEC(3,3),WSEC2(3,3)
C
C  ************  Transfer partial counters to global counters.
C
      DO KPAR=1,3
      DO IEXIT=1,2
      DO IE=1,NBE
        PDE(KPAR,IEXIT,IE)=PDE(KPAR,IEXIT,IE)+PDEP(KPAR,IEXIT,IE)
        PDE2(KPAR,IEXIT,IE)=PDE2(KPAR,IEXIT,IE)+PDEP(KPAR,IEXIT,IE)**2
        PDEP(KPAR,IEXIT,IE)=0.0D0
        LPDE(KPAR,IEXIT,IE)=0
      ENDDO
      ENDDO
      ENDDO
C
      DO KPAR=1,3
      DO KTH=1,NBTH
      DO KPH=1,NBPH
        PDA(KPAR,KTH,KPH)=PDA(KPAR,KTH,KPH)+PDAP(KPAR,KTH,KPH)
        PDA2(KPAR,KTH,KPH)=PDA2(KPAR,KTH,KPH)+PDAP(KPAR,KTH,KPH)**2
        PDAP(KPAR,KTH,KPH)=0.0D0
        LPDA(KPAR,KTH,KPH)=0
      ENDDO
      ENDDO
      ENDDO
C
      IF(NDIDEF.GT.0) THEN
        DO ID=1,NDIDEF
        DO J=1,NDICH(ID)
          DIT(ID,J)=DIT(ID,J)+DITP(ID,J)
          DIT2(ID,J)=DIT2(ID,J)+DITP(ID,J)**2
          DITP(ID,J)=0.0D0
          LDIT(ID,J)=0
        ENDDO
        DO J=1,NDICH(ID)
        DO K=1,3
          DIP(ID,J,K)=DIP(ID,J,K)+DIPP(ID,J,K)
          DIP2(ID,J,K)=DIP2(ID,J,K)+DIPP(ID,J,K)**2
          DIPP(ID,J,K)=0.0D0
          LDIP(ID,J,K)=0
        ENDDO
        ENDDO
        ENDDO
      ENDIF
C
      IF(NDIDEF.GT.0) THEN
        DO ID=1,NDIDEF
        DO J=1,NDICH(ID)
          FST(ID,J)=FST(ID,J)+FSTP(ID,J)
          FST2(ID,J)=FST2(ID,J)+FSTP(ID,J)**2
          FSTP(ID,J)=0.0D0
          LFST(ID,J)=0
        ENDDO
        DO J=1,NDICH(ID)
        DO K=1,3
          FSP(ID,J,K)=FSP(ID,J,K)+FSPP(ID,J,K)
          FSP2(ID,J,K)=FSP2(ID,J,K)+FSPP(ID,J,K)**2
          FSPP(ID,J,K)=0.0D0
          LFSP(ID,J,K)=0
        ENDDO
        ENDDO
        ENDDO
      ENDIF
C
      IF(LDOSEM) THEN
        DO I3=1,NDB(3)
        DO I2=1,NDB(2)
        DO I1=1,NDB(1)
          DOSE(I1,I2,I3)=DOSE(I1,I2,I3)+DOSEP(I1,I2,I3)
          DOSE2(I1,I2,I3)=DOSE2(I1,I2,I3)+DOSEP(I1,I2,I3)**2
          DOSEP(I1,I2,I3)=0.0D0
          LDOSE(I1,I2,I3)=0
        ENDDO
        ENDDO
          DDOSE(I3)=DDOSE(I3)+DDOSEP(I3)
          DDOSE2(I3)=DDOSE2(I3)+DDOSEP(I3)**2
          DDOSEP(I3)=0.0D0
          LDDOSE(I3)=0
        ENDDO
      ENDIF
C
      IF(NPSFO.GT.0) THEN
        CALL WRPSF(IPSFO,0,ICLOSE)
      ENDIF
C
C  ************  If 'DUMPTO' is active, write counters in a dump file.
C
      IF(LDUMP) THEN
        OPEN(9,FILE=PFILED)
        WRITE(9,*) SHN,TSIM
        WRITE(9,'(A65)') TITLE
        WRITE(9,*) ISEED1,ISEED2
        WRITE(9,*) NPSN,RLREAD
        WRITE(9,*) (SHIST(I),I=1,NSEB)
        WRITE(9,*) (PRIM(I),I=1,3),(PRIM2(I),I=1,3)
        WRITE(9,*) ((SEC(K,I),I=1,3),K=1,3),((SEC2(K,I),I=1,3),K=1,3)
        WRITE(9,*) (TDEBO(I),I=1,NBODY), (TDEBO2(I),I=1,NBODY)
        WRITE(9,*) (((PDE(I,J,K),K=1,NBE),J=1,2),I=1,3),
     1             (((PDE2(I,J,K),K=1,NBE),J=1,2),I=1,3)
        WRITE(9,*) (((PDA(I,J,K),K=1,NBPH),J=1,NBTH),I=1,3),
     1             (((PDA2(I,J,K),K=1,NBPH),J=1,NBTH),I=1,3)
        WRITE(9,*) (TDID(I),I=1,NIDM), (TDID2(I),I=1,NIDM)
        WRITE(9,*) (TDED(I),I=1,NEDM), (TDED2(I),I=1,NEDM)
        IF(NDIDEF.GT.0) THEN
          WRITE(9,*) RLAST,RWRITE
          DO ID=1,NDIDEF
            WRITE(9,*) (DIT(ID,J),J=1,NDICH(ID))
            WRITE(9,*) (DIT2(ID,J),J=1,NDICH(ID))
            WRITE(9,*) ((DIP(ID,J,K),J=1,NDICH(ID)),K=1,3)
            WRITE(9,*) ((DIP2(ID,J,K),J=1,NDICH(ID)),K=1,3)
            IF(IDCUT(ID).EQ.2) THEN
              WRITE(9,*) (FST(ID,J),J=1,NDICH(ID))
              WRITE(9,*) (FST2(ID,J),J=1,NDICH(ID))
              WRITE(9,*) ((FSP(ID,J,K),J=1,NDICH(ID)),K=1,3)
              WRITE(9,*) ((FSP2(ID,J,K),J=1,NDICH(ID)),K=1,3)
            ENDIF
          ENDDO
        ENDIF
        IF(NDEDEF.GT.0) THEN
          DO ID=1,NDEDEF
            WRITE(9,*) (DET(ID,J),J=1,NDECH(ID))
          ENDDO
        ENDIF
        IF(LDOSEM) THEN
          WRITE(9,*)
     1      (((DOSE(I1,I2,I3),I3=1,NDB(3)),I2=1,NDB(2)),I1=1,NDB(1)),
     1      (((DOSE2(I1,I2,I3),I3=1,NDB(3)),I2=1,NDB(2)),I1=1,NDB(1))
          WRITE(9,*) (DDOSE(I3),I3=1,NDB(3)),(DDOSE2(I3),I3=1,NDB(3))
        ENDIF
        WRITE(9,'(/3X,''*** END ***'')')
        CLOSE(9)
      ENDIF
C
C  ------------------------  Print simulation results.
C
C     IEXIT: 1=upbound, 2=downbound, 3=absorbed.
C
      OPEN(27,FILE='penmain-res.dat')
      WRITE(27,3000)
 3000 FORMAT(//3X,35('*')/3X,'**   Program PENMAIN. Results.   **',
     1  /3X,35('*'))
C
      WRITE(27,1001) DATE23
 1001 FORMAT(/3X,'Date and time: ',A23)
      WRITE(27,'(/3X,A65)') TITLE
C
      WRITE(27,3001) TSIM
 3001 FORMAT(/3X,'Simulation time ......................... ',
     1  1P,E13.6,' sec')
      TAVS=SHN/TSIM
      WRITE(27,3002) TAVS
 3002 FORMAT(3X,'Simulation speed ........................ ',
     1  1P,E13.6,' showers/sec')
      WRITE(27,3003) SHN
 3003 FORMAT(//3X,'Simulated primary showers ............... ',
     1  1P,E13.6)
C
      IF(KPARP.EQ.1) WRITE(27,1110)
 1110 FORMAT(/3X,'Primary particles: electrons')
      IF(KPARP.EQ.2) WRITE(27,1111)
 1111 FORMAT(/3X,'Primary particles: photons')
      IF(KPARP.EQ.3) WRITE(27,1112)
 1112 FORMAT(/3X,'Primary particles: positrons')
      IF(KPARP.EQ.0) WRITE(26,1113)
 1113 FORMAT(/3X,'Primary particles: set by the user subroutine SOURCE')
C
      WRITE(27,3004) PRIM(1)
 3004 FORMAT(/3X,'Upbound primary particles ............... ',
     1  1P,E13.6)
      WRITE(27,3005) PRIM(2)
 3005 FORMAT(3X,'Downbound primary particles ............. ',
     1  1P,E13.6)
      WRITE(27,3006) PRIM(3)
 3006 FORMAT(3X,'Absorbed primary particles .............. ',
     1  1P,E13.6)
C
      FNT=1.0D0/SHN
      FT=(PRIM(1)+SEC(KPARP,1))*FNT
      ERR1=3.0D0*FNT*SQRT(ABS(PRIM2(1)-PRIM(1)**2*FNT))
      ERR2=3.0D0*FNT*SQRT(ABS(SEC2(KPARP,1)-SEC(KPARP,1)**2*FNT))
      ERR=ERR1+ERR2
      WRITE(27,3007) FT,ERR
 3007 FORMAT(/3X,'Upbound fraction ................... ',
     1  1P,E13.6,' +-',E8.1)
      FB=(PRIM(2)+SEC(KPARP,2))*FNT
      ERR1=3.0D0*FNT*SQRT(ABS(PRIM2(2)-PRIM(2)**2*FNT))
      ERR2=3.0D0*FNT*SQRT(ABS(SEC2(KPARP,2)-SEC(KPARP,2)**2*FNT))
      ERR=ERR1+ERR2
      WRITE(27,3008) FB,ERR
 3008 FORMAT(3X,'Downbound fraction ................. ',
     1  1P,E13.6,' +-',E8.1)
      FA=PRIM(3)*FNT
      ERR=3.0D0*FNT*SQRT(ABS(PRIM2(3)-PRIM(3)**2*FNT))
      WRITE(27,3009) FA,ERR
 3009 FORMAT(3X,'Absorption fraction ................ ',
     1  1P,E13.6,' +-',E8.1)
C
      DO K=1,3
        DO I=1,3
          WSEC2(K,I)=3.0D0*FNT*SQRT(ABS(SEC2(K,I)-SEC(K,I)**2*FNT))
          WSEC(K,I)=SEC(K,I)*FNT
        ENDDO
      ENDDO
      WRITE(27,3010)
     1  WSEC(1,1),WSEC(2,1),WSEC(3,1),WSEC2(1,1),WSEC2(2,1),WSEC2(3,1),
     1  WSEC(1,2),WSEC(2,2),WSEC(3,2),WSEC2(1,2),WSEC2(2,2),WSEC2(3,2),
     1  WSEC(1,3),WSEC(2,3),WSEC(3,3),WSEC2(1,3),WSEC2(2,3),WSEC2(3,3)
 3010 FORMAT(/3X,'Secondary-particle generation probabilities:',
     1  /19X,46('-'),
     1  /19X,'|  electrons   |   photons    |  positrons   |',1P,
     1  /3X,62('-')/3X,'|   upbound     |',3(E13.6,1X,'|'),
     1  /3X,'|               |',3('  +-',E8.1,2X,'|'),
     1  /3X,62('-')/3X,'|   downbound   |',3(E13.6,1X,'|'),
     1  /3X,'|               |',3('  +-',E8.1,2X,'|'),
     1  /3X,62('-')/3X,'|   absorbed    |',3(E13.6,1X,'|'),
     1  /3X,'|               |',3('  +-',E8.1,2X,'|'),
     1  /3X,62('-'))
C
C  ****  Average energies deposited in bodies..
C
      DF=1.0D0/SHN
      WRITE(27,3011)
 3011 FORMAT(/3X,'Average deposited energies (bodies):')
      DO KB=1,NBODY
        IF(MATER(KB).NE.0) THEN
          QER=3.0D0*DF*SQRT(ABS(TDEBO2(KB)-TDEBO(KB)**2*DF))
          QAV=TDEBO(KB)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(27,3012) KB,QAV,QER,EFFIC
        ENDIF
      ENDDO
 3012 FORMAT(6X,'Body ',I4, ' ...... ',1P,E13.6,' +-',E8.1,' eV',4X,
     1  '(effic. =',E9.2,')')
C
C  ****  Average energies 'collected' by impact detectors.
C
      IF(NDIDEF.GT.0) THEN
        WRITE(27,3013)
 3013   FORMAT(/3X,'Average incoming energies (impact detectors):')
        DO KD=1,NDIDEF
          QER=3.0D0*DF*SQRT(ABS(TDID2(KD)-TDID(KD)**2*DF))
          QAV=TDID(KD)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(27,3014) KD,QAV,QER,EFFIC
        ENDDO
      ENDIF
 3014 FORMAT(6X,'Detector #',I2,' ... ',1P,E13.6,' +-',E8.1,' eV',4X,
     1  '(effic. =',E9.2,')')
C
C  ****  Average deposited energies in energy-deposition detectors.
C
      IF(NDEDEF.GT.0) THEN
        WRITE(27,3015)
 3015   FORMAT(/3X,'Average deposited energies (energy detectors):')
        DO KD=1,NDEDEF
          QER=3.0D0*DF*SQRT(ABS(TDED2(KD)-TDED(KD)**2*DF))
          QAV=TDED(KD)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(27,3014) KD,QAV,QER,EFFIC
        ENDDO
      ENDIF
C
C  ****  Detector efficiencies.
C
      IF(NDIDEF.GT.0) THEN
        WRITE(27,3016)
 3016   FORMAT(/3X,'Detection efficiencies (impact detectors):')
        DO KD=1,NDIDEF
          SUM=0.0D0
          ESUM=0.0D0
          DO J=1,NDICH(KD)
            YERR=3.0D0*SQRT(ABS(DIT2(KD,J)-DIT(KD,J)**2*DF))
            YAV=MAX(DIT(KD,J)*DF,1.0D-35)
            YERR=MAX(YERR*DF,1.0D-35)
            SUM=SUM+YAV
            ESUM=ESUM+YERR
          ENDDO
          WRITE(27,3017) KD,SUM,ESUM
        ENDDO
      ENDIF
 3017 FORMAT(6X,'Detector #',I2,' ... ',1P,E13.6,' +-',E8.1)
C
      IF(NDEDEF.GT.0) THEN
        WRITE(27,3018)
 3018   FORMAT(/3X,'Detection efficiencies (energy detectors):')
        DO KD=1,NDEDEF
          SUM=0.0D0
          ESUM=0.0D0
          DO J=1,NDECH(KD)
            YAV=DET(KD,J)*DF
            YERR=3.0D0*SQRT(ABS(YAV*(1.0D0-YAV))*DF)
            SUM=SUM+YAV
            ESUM=ESUM+YERR
          ENDDO
          WRITE(27,3017) KD,SUM,ESUM
        ENDDO
      ENDIF
C
C  ************  Energy spectrum of the source.
C
      IF(LSPEC) THEN
        OPEN(9,FILE='psource.dat')
        WRITE(9,9000)
 9000 FORMAT(
     1  1X,'#  Results from PENMAIN. ',
     1 /1X,'#  Source energy spectrum.',
     1 /1X,'#  1st column: E (eV). 2nd column: spectrum (1/eV).',
     1 /1X,'#  3rd and 4th columns: simul. pdf limits (3SD, 1/eV).',/)
        PTOT=0.0D0
        WRITE(9,'(1X,1P,4E14.6)') ES(1),PTOT,PTOT,PTOT
        DO KE=1,NSEB
          PTOT=PTOT+PTS(KE)
        ENDDO
        IF(PTOT.GT.1.0D-35) THEN
          DO KE=1,NSEB
            YAV=SHIST(KE)*DF
            YERR=3.0D0*SQRT(ABS(YAV*(1.0D0-YAV)*DF))
            EINTL=ES(KE+1)-ES(KE)
            IF(EINTL.GT.1.0D-15) THEN
              FACT=1.0D0/EINTL
            ELSE
              FACT=1.0D15
            ENDIF
            WRITE(9,'(1X,1P,4E14.6)') ES(KE),PTS(KE)*FACT/PTOT,
     1        (YAV-YERR)*FACT,(YAV+YERR)*FACT
            WRITE(9,'(1X,1P,4E14.6)') ES(KE+1),PTS(KE)*FACT/PTOT,
     1        (YAV-YERR)*FACT,(YAV+YERR)*FACT
          ENDDO
          PTOT=0.0D0
          WRITE(9,'(1X,1P,4E14.6)') ES(NSEB+1),PTOT,PTOT,PTOT
        ELSE
          DO KE=1,NSEB
            EINTL=DBLE(KE-1)*DSHE
            YAV=SHIST(KE)*DF
            YERR=3.0D0*SQRT(ABS(YAV*(1.0D0-YAV)*DF))
            WRITE(9,'(1X,1P,4E14.6)') EINTL,YAV*RDSHE,
     1        (YAV-YERR)*RDSHE,(YAV+YERR)*RDSHE
            WRITE(9,'(1X,1P,4E14.6)') EINTL+DSHE,YAV*RDSHE,
     1        (YAV-YERR)*RDSHE,(YAV+YERR)*RDSHE
          ENDDO
        ENDIF
        CLOSE(9)
      ENDIF
C
C  ************  Energy distributions of emerging particles.
C
C  ****  Upbound electrons.
      OPEN(9,FILE='energy-el-up.dat')
      WRITE(9,9110)
 9110 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of upbound electrons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(1,1,K)-PDE(1,1,K)**2*DF))
        YAV=PDE(1,1,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C  ****  Downbound electrons.
      OPEN(9,FILE='energy-el-down.dat')
      WRITE(9,9120)
 9120 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of downbound electrons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(1,2,K)-PDE(1,2,K)**2*DF))
        YAV=PDE(1,2,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C  ****  Upbound photons.
      OPEN(9,FILE='energy-ph-up.dat')
      WRITE(9,9130)
 9130 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of upbound photons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(2,1,K)-PDE(2,1,K)**2*DF))
        YAV=PDE(2,1,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C  ****  Downbound photons.
      OPEN(9,FILE='energy-ph-down.dat')
      WRITE(9,9140)
 9140 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of downbound photons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(2,2,K)-PDE(2,2,K)**2*DF))
        YAV=PDE(2,2,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C  ****  Upbound positrons.
      OPEN(9,FILE='energy-po-up.dat')
      WRITE(9,9150)
 9150 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of upbound positrons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(3,1,K)-PDE(3,1,K)**2*DF))
        YAV=PDE(3,1,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C  ****  Downbound positrons.
      OPEN(9,FILE='energy-po-down.dat')
      WRITE(9,9160)
 9160 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Energy distribution of downbound positrons.',
     1 /1X,'#  1st column: E (eV).',
     1 /1X,'#  2nd and 3rd columns: probability density and STU',
     1         ' (1/(eV*particle)).',/)
      DO K=1,NBE
        XX=EMIN+(K-0.5D0)*BSE
        YERR=3.0D0*SQRT(ABS(PDE2(3,2,K)-PDE(3,2,K)**2*DF))
        YAV=PDE(3,2,K)*DF*RBSE
        YERR=YERR*DF*RBSE
        WRITE(9,'(1X,1P,3E14.6)')
     1     XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
      ENDDO
      CLOSE(9)
C
C  ************  Angular distributions of emerging particles.
C
      IF(NBPH.EQ.1) THEN
        OPEN(9,FILE='polar-angle-el.dat')
      ELSE
        OPEN(9,FILE='angle-el.dat')
      ENDIF
      WRITE(9,9210)
 9210 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Angular distribution of emerging electrons.',
     1 /1X,'#  1st and 2nd columns: THETA and PHI (deg).',
     1 /1X,'#  3rd and 4th columns: probability density and STU',
     1         ' (1/sr)',/)
      DO K=1,NBTH
        XX=(K-0.5D0)*BSTH
        XXR=(K-1.0D0)*BSTH*DE2RA
        DSANG=(COS(XXR)-COS(XXR+BSTH*DE2RA))*(BSPH*DE2RA)
        DO L=1,NBPH
          YY=(L-0.5D0)*BSPH
          YERR=3.0D0*SQRT(ABS(PDA2(1,K,L)-PDA(1,K,L)**2*DF))
          YAV=PDA(1,K,L)*DF/DSANG
          YERR=YERR*DF/DSANG
          WRITE(9,'(1X,1P,6E14.6)')
     1       XX,YY,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        IF(NBPH.GT.1) WRITE(9,*) '   '
      ENDDO
      CLOSE(9)
C
      IF(NBPH.EQ.1) THEN
        OPEN(9,FILE='polar-angle-ph.dat')
      ELSE
        OPEN(9,FILE='angle-ph.dat')
      ENDIF
      WRITE(9,9220)
 9220 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Angular distribution of emerging photons.',
     1 /1X,'#  1st and 2nd columns: THETA and PHI (deg).',
     1 /1X,'#  3rd and 4th columns: probability density and STU',
     1         ' (1/sr)',/)
      DO K=1,NBTH
        XX=(K-0.5D0)*BSTH
        XXR=(K-1.0D0)*BSTH*DE2RA
        DSANG=(COS(XXR)-COS(XXR+BSTH*DE2RA))*(BSPH*DE2RA)
        DO L=1,NBPH
          YY=(L-0.5D0)*BSPH
          YERR=3.0D0*SQRT(ABS(PDA2(2,K,L)-PDA(2,K,L)**2*DF))
          YAV=PDA(2,K,L)*DF/DSANG
          YERR=YERR*DF/DSANG
          WRITE(9,'(1X,1P,6E14.6)')
     1       XX,YY,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        IF(NBPH.GT.1) WRITE(9,*) '   '
      ENDDO
      CLOSE(9)
C
      IF(NBPH.EQ.1) THEN
        OPEN(9,FILE='polar-angle-po.dat')
      ELSE
        OPEN(9,FILE='angle-po.dat')
      ENDIF
      WRITE(9,9230)
 9230 FORMAT(
     1  1X,'#  Results from PENMAIN.',
     1 /1X,'#  Angular distribution of emerging positrons.',
     1 /1X,'#  1st and 2nd columns: THETA and PHI (deg).',
     1 /1X,'#  3rd and 4th columns: probability density and STU',
     1         ' (1/sr)',/)
      DO K=1,NBTH
        XX=(K-0.5D0)*BSTH
        XXR=(K-1.0D0)*BSTH*DE2RA
        DSANG=(COS(XXR)-COS(XXR+BSTH*DE2RA))*(BSPH*DE2RA)
        DO L=1,NBPH
          YY=(L-0.5D0)*BSPH
          YERR=3.0D0*SQRT(ABS(PDA2(3,K,L)-PDA(3,K,L)**2*DF))
          YAV=PDA(3,K,L)*DF/DSANG
          YERR=YERR*DF/DSANG
          WRITE(9,'(1X,1P,6E14.6)')
     1       XX,YY,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        IF(NBPH.GT.1) WRITE(9,*) '   '
      ENDDO
      CLOSE(9)
C
C  ************  Spectra from impact detectors.
C
      IF(NDIDEF.GT.0) THEN
        DO ID=1,NDIDEF
          OPEN(9,FILE=SPCDIO(ID))
          WRITE(9,9310) ID
 9310 FORMAT(
     1  1X,'#  Results from PENMAIN. Output from impact detector #',I3,
     1 /1X,'#  Energy spectra of incident particles.',
     1 /1X,'#  1st column: particle energy (eV).',
     1 /1X,'#  2nd column: probability density (1/(eV*particle)).',
     1 /1X,'#  3rd column: statistical uncertainty, STU (3 sigma).',
     1 /1X,'#  4th-5th columns: electron spectrum and STU (3 sigma).',
     1 /1X,'#  6th-7th columns: photon spectrum and STU (3 sigma).',
     1 /1X,'#  8th-9th columns: positron spectrum and STU (3 sigma).',/)
          DO J=1,NDICH(ID)
            IF(LDILOG(ID)) THEN
              XLOW=EXP(EDILL(ID)+(J-1)*BDIEL(ID))
              XUPP=EXP(EDILL(ID)+J*BDIEL(ID))
              XX=0.5D0*(XUPP+XLOW)
              BINS=XUPP-XLOW
            ELSE
              XX=EDIL(ID)+(J-0.5D0)*BDIE(ID)
              BINS=BDIE(ID)
            ENDIF
            YERR=3.0D0*SQRT(ABS(DIT2(ID,J)-DIT(ID,J)**2*DF))
            YAV=MAX(DIT(ID,J)*DF/BINS,1.0D-35)
            YERR=MAX(YERR*DF/BINS,1.0D-35)
C
            YERR1=3.0D0*SQRT(ABS(DIP2(ID,J,1)-DIP(ID,J,1)**2*DF))
            YAV1=MAX(DIP(ID,J,1)*DF/BINS,1.0D-35)
            YERR1=MAX(YERR1*DF/BINS,1.0D-35)
C
            YERR2=3.0D0*SQRT(ABS(DIP2(ID,J,2)-DIP(ID,J,2)**2*DF))
            YAV2=MAX(DIP(ID,J,2)*DF/BINS,1.0D-35)
            YERR2=MAX(YERR2*DF/BINS,1.0D-35)
C
            YERR3=3.0D0*SQRT(ABS(DIP2(ID,J,3)-DIP(ID,J,3)**2*DF))
            YAV3=MAX(DIP(ID,J,3)*DF/BINS,1.0D-35)
            YERR3=MAX(YERR3*DF/BINS,1.0D-35)
            WRITE(9,'(1X,1P,E14.6,4(E14.6,E10.2))')
     1        XX,YAV,YERR,YAV1,YERR1,YAV2,YERR2,YAV3,YERR3
          ENDDO
          CLOSE(9)
        ENDDO
      ENDIF
C
C  ************  Distributions of fluence with respect to energy
C                (integrated over the volume of the impact detectors).
C
      IF(NDIDEF.GT.0) THEN
        DO ID=1,NDIDEF
          IF(IDCUT(ID).EQ.2) THEN
          OPEN(9,FILE=SPCFSO(ID))
          WRITE(9,9330) ID
 9330 FORMAT(
     1  1X,'#  Results from PENMAIN. Output from impact detector #',I3,
     1 /1X,'#  Fluences integrated over the volume of the detector ',
     1   '(in cm/(eV*particle)).',
     1 /1X,'#  1st column: particle energy (eV).',
     1 /1X,'#  2nd column: energy distribution of total fluence.',
     1 /1X,'#  3rd column: statistical uncertainty, STU (3 sigma).',
     1 /1X,'#  4th-5th columns: electron fluence and STU (3 sigma).',
     1 /1X,'#  6th-7th columns: photon fluence and STU (3 sigma).',
     1 /1X,'#  8th-9th columns: positron fluence and STU (3 sigma).',/)
          DO J=1,NDICH(ID)
            IF(LDILOG(ID)) THEN
              XLOW=EXP(EDILL(ID)+(J-1)*BDIEL(ID))
              XUPP=EXP(EDILL(ID)+J*BDIEL(ID))
              XX=0.5D0*(XUPP+XLOW)
              BINS=XUPP-XLOW
            ELSE
              XX=EDIL(ID)+(J-0.5D0)*BDIE(ID)
              BINS=BDIE(ID)
            ENDIF
            YERR=3.0D0*SQRT(ABS(FST2(ID,J)-FST(ID,J)**2*DF))
            YAV=MAX(FST(ID,J)*DF/BINS,1.0D-35)
            YERR=MAX(YERR*DF/BINS,1.0D-35)
C
            YERR1=3.0D0*SQRT(ABS(FSP2(ID,J,1)-FSP(ID,J,1)**2*DF))
            YAV1=MAX(FSP(ID,J,1)*DF/BINS,1.0D-35)
            YERR1=MAX(YERR1*DF/BINS,1.0D-35)
C
            YERR2=3.0D0*SQRT(ABS(FSP2(ID,J,2)-FSP(ID,J,2)**2*DF))
            YAV2=MAX(FSP(ID,J,2)*DF/BINS,1.0D-35)
            YERR2=MAX(YERR2*DF/BINS,1.0D-35)
C
            YERR3=3.0D0*SQRT(ABS(FSP2(ID,J,3)-FSP(ID,J,3)**2*DF))
            YAV3=MAX(FSP(ID,J,3)*DF/BINS,1.0D-35)
            YERR3=MAX(YERR3*DF/BINS,1.0D-35)
            WRITE(9,'(1X,1P,E14.6,4(E14.6,E10.2))')
     1        XX,YAV,YERR,YAV1,YERR1,YAV2,YERR2,YAV3,YERR3
          ENDDO
          CLOSE(9)
          ENDIF
        ENDDO
      ENDIF
C
C  ************  Spectra from energy-deposition detectors.
C
      IF(NDEDEF.GT.0) THEN
        DO ID=1,NDEDEF
          OPEN(9,FILE=SPCDEO(ID))
          WRITE(9,9320) ID
 9320 FORMAT(
     1  1X,'#  Results from PENMAIN. Output from energy-deposition',
     1  ' detector #',I3,
     1 /1X,'#  Deposited energy spectrum.',
     1 /1X,'#  WARNING: May be strongly biased if interaction ',
     1  'forcing is used!',
     1 /1X,'#  1st column: deposited energy (eV).',
     1 /1X,'#  2nd column: probability density (1/(eV*particle)).',
     1 /1X,'#  3rd column: statistical uncertainty (3 sigma).',/)
          DO J=1,NDECH(ID)
            IF(LDELOG(ID)) THEN
              XLOW=EXP(EDELL(ID)+(J-1)*BDEEL(ID))
              XUPP=EXP(EDELL(ID)+J*BDEEL(ID))
              XX=0.5D0*(XUPP+XLOW)
              BINS=XUPP-XLOW
            ELSE
              XX=EDEL(ID)+(J-0.5D0)*BDEE(ID)
              BINS=BDEE(ID)
            ENDIF
            YAV=DET(ID,J)*DF
            YERR=3.0D0*SQRT(ABS(YAV*(1.0D0-YAV))*DF)
            YAV=YAV/BINS
            YERR=YERR/BINS
            WRITE(9,'(1X,1P,3E14.6)')
     1        XX,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
          ENDDO
          CLOSE(9)
        ENDDO
      ENDIF
C
C  ************  Dose distributions.
C
      IF(LDOSEM) THEN
C
C  ****  Depth-dose distribution.
C
        OPEN(9,FILE='depth-dose.dat')
        WRITE(9,9410)
 9410   FORMAT(
     1     1X,'#  Results from PENMAIN. Depth-dose distribution.',
     1    /1X,'#  (integrated over X and Y within the volume of the ',
     1      'dose-map box).',
     1    /1X,'#  1st column: z coordinate (cm).',
     1    /1X,'#  2nd column: depth-dose (eV/(g/cm**2)).',
     1    /1X,'#  3rd column: statistical uncertainty (3 sigma).',/)
        DO I3=1,NDB(3)
          ZZ=DXL(3)+(I3-0.5D0)*BDOSE(3)
          YAV=DDOSE(I3)
          YAV2=DDOSE2(I3)
          YERR=3.0D0*SQRT(ABS(YAV2-YAV**2*DF))
          YAV=YAV*DF/BDOSE(3)
          YERR=YERR*DF/BDOSE(3)
          WRITE(9,'(1X,1P,3E14.6)')
     1      ZZ,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        CLOSE(9)
C
        VOXEL=BDOSE(1)*BDOSE(2)*BDOSE(3)
        DMAX=0.0D0
        I1M=1
        I2M=1
        I3M=1
        DO I1=1,NDB(1)
          DO I2=1,NDB(2)
            DO I3=1,NDB(3)
              IF(DOSE(I1,I2,I3).GT.DMAX) THEN
                I1M=I1
                I2M=I2
                I3M=I3
                DMAX=DOSE(I1,I2,I3)
              ENDIF
            ENDDO
          ENDDO
        ENDDO
C
        QAV=DOSE(I1M,I2M,I3M)
        QAV2=DOSE2(I1M,I2M,I3M)
        QER=3.0D0*SQRT(ABS(QAV2-QAV**2*DF))
        QAV=QAV*DF/VOXEL
        QER=QER*DF/VOXEL
        IF(QER.GT.1.0D-10*ABS(QAV)) THEN
          EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
        ELSE
          EFFIC=0.0D0
        ENDIF
        WRITE(27,3020) QAV,QER,EFFIC
 3020   FORMAT(/6X,'Maximum dose ... ',1P,E13.6,' +-',E8.1,' eV/g',2X,
     1    '(effic. =',E9.2,')')
C
        OPEN(9,FILE='3d-dose.dat')
        WRITE(9,9420)
 9420   FORMAT(1X,'#  Results from PENMAIN. 3D dose distribution.')
        WRITE(9,9421) DXL(1),DXU(1)
 9421   FORMAT(1X,'#  Dose-map box:  XL = ',1P,E13.6,
     1    ' cm,  XU = ',E13.6,' cm')
        WRITE(9,9422) DXL(2),DXU(2)
 9422   FORMAT(1X,'#',17X,'YL = ',1P,E13.6,' cm,  YU = ',E13.6,' cm')
        WRITE(9,9423) DXL(3),DXU(3)
 9423   FORMAT(1X,'#',17X,'ZL = ',1P,E13.6,' cm,  ZU = ',E13.6,' cm')
        WRITE(9,9424) NDB(1),NDB(2),NDB(3)
 9424   FORMAT(1X,'#  Numbers of bins:     NBX =',I4,', NBY =',I4,
     1        ', NBZ =',I4,/1X,'#')
        WRITE(9,9425)
 9425   FORMAT(1X,'#  columns 1 to 3: coordinates X,Y,Z of the bin',
     1    ' centres',/1X,'#  4th column: dose (eV/g).',
     1    /1X,'#  5th column: statistical uncertainty (3 sigma).',
     1    /1X,'#  columns 6 to 8: bin indices IX,IY,IZ.',/)
        DO I3=1,NDB(3)
          ZZ=DXL(3)+(I3-0.5D0)*BDOSE(3)
          DO I1=1,NDB(1)
            XX=DXL(1)+(I1-0.5D0)*BDOSE(1)
            DO I2=1,NDB(2)
              YY=DXL(2)+(I2-0.5D0)*BDOSE(2)
              YAV=DOSE(I1,I2,I3)
              YAV2=DOSE2(I1,I2,I3)
              YERR=3.0D0*SQRT(ABS(YAV2-YAV**2*DF))
              YAV=MAX(YAV*DF/VOXEL,1.0D-35)
              YERR=MAX(YERR*DF/VOXEL,1.0D-35)
              WRITE(9,9426) XX,YY,ZZ,YAV,YERR,I1,I2,I3
            ENDDO
            WRITE(9,*) '   '
          ENDDO
          WRITE(9,*) '   '
        ENDDO
 9426   FORMAT(1P,3E11.3,1P,E13.5,E9.1,3I4)
        CLOSE(9)
C
C  ****  Dose distributions at the central axes.
C
        I1C=(NDB(1)/2)+1
        I2C=(NDB(2)/2)+1
        I3C=(NDB(3)/2)+1
C
        OPEN(9,FILE='x-dose.dat')
          WRITE(9,9440)
 9440   FORMAT(
     1     1X,'#  Results from PENMAIN.',
     1    /1X,'#  Dose distribution along the central X axis',
     1    /1X,'#  1st column: x (cm).',
     1    /1X,'#  2nd column: dose (eV/g).',
     1    /1X,'#  3rd column: statistical uncertainty (3 sigma).',/)
        DO I1=1,NDB(1)
          XYZ=DXL(1)+(I1-0.5D0)*BDOSE(1)
          YAV=DOSE(I1,I2C,I3C)
          YAV2=DOSE2(I1,I2C,I3C)
          YERR=3.0D0*SQRT(ABS(YAV2-YAV**2*DF))
          YAV=YAV*DF/VOXEL
          YERR=YERR*DF/VOXEL
          WRITE(9,'(1X,1P,3E14.6)')
     1      XYZ,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        CLOSE(9)
C
        OPEN(9,FILE='y-dose.dat')
          WRITE(9,9450)
 9450   FORMAT(
     1     1X,'#  Results from PENMAIN.',
     1    /1X,'#  Dose distribution along the central Y axis',
     1    /1X,'#  1st column: y (cm).',
     1    /1X,'#  2nd column: dose (eV/g).',
     1    /1X,'#  3rd column: statistical uncertainty (3 sigma).',/)
        DO I2=1,NDB(2)
          XYZ=DXL(2)+(I2-0.5D0)*BDOSE(2)
          YAV=DOSE(I1C,I2,I3C)
          YAV2=DOSE2(I1C,I2,I3C)
          YERR=3.0D0*SQRT(ABS(YAV2-YAV**2*DF))
          YAV=YAV*DF/VOXEL
          YERR=YERR*DF/VOXEL
          WRITE(9,'(1X,1P,3E14.6)')
     1      XYZ,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        CLOSE(9)
C
        OPEN(9,FILE='z-dose.dat')
          WRITE(9,9460)
 9460   FORMAT(
     1     1X,'#  Results from PENMAIN.',
     1    /1X,'#  Dose distribution along the central Z axis',
     1    /1X,'#  1st column: z (cm).',
     1    /1X,'#  2nd column: dose (eV/g).',
     1    /1X,'#  3rd column: statistical uncertainty (3 sigma).',/)
        DO I3=1,NDB(3)
          XYZ=DXL(3)+(I3-0.5D0)*BDOSE(3)
          YAV=DOSE(I1C,I2C,I3)
          YAV2=DOSE2(I1C,I2C,I3)
          YERR=3.0D0*SQRT(ABS(YAV2-YAV**2*DF))
          YAV=YAV*DF/VOXEL
          YERR=YERR*DF/VOXEL
          WRITE(9,'(1X,1P,3E14.6)')
     1      XYZ,MAX(YAV,1.0D-35),MAX(YERR,1.0D-35)
        ENDDO
        CLOSE(9)
      ENDIF
C
      WRITE(27,3030) ISEED1,ISEED2
 3030 FORMAT(/3X,'Last random seeds = ',I10,' , ',I10)
      WRITE(27,'(/3X,72(''-''))')
      CLOSE(27)
      IF(ICLOSE.LT.0) RETURN
C
C  ************  Write final average results in output file.
C
      WRITE(26,'(/3X,72(''-''))')
      WRITE(26,3000)
      WRITE(26,1001) DATE23
      WRITE(26,'(/3X,A65)') TITLE
C
      WRITE(26,3001) TSIM
      WRITE(26,3002) TAVS
      WRITE(26,3003) SHN
C
      IF(KPARP.EQ.1) WRITE(26,1110)
      IF(KPARP.EQ.2) WRITE(26,1111)
      IF(KPARP.EQ.3) WRITE(26,1112)
      IF(KPARP.EQ.0) WRITE(26,1113)
C
      WRITE(26,3004) PRIM(1)
      WRITE(26,3005) PRIM(2)
      WRITE(26,3006) PRIM(3)
C
      FNT=1.0D0/SHN
      FT=(PRIM(1)+SEC(KPARP,1))*FNT
      ERR1=3.0D0*FNT*SQRT(ABS(PRIM2(1)-PRIM(1)**2*FNT))
      ERR2=3.0D0*FNT*SQRT(ABS(SEC2(KPARP,1)-SEC(KPARP,1)**2*FNT))
      ERR=ERR1+ERR2
      WRITE(26,3007) FT,ERR
      FB=(PRIM(2)+SEC(KPARP,2))*FNT
      ERR1=3.0D0*FNT*SQRT(ABS(PRIM2(2)-PRIM(2)**2*FNT))
      ERR2=3.0D0*FNT*SQRT(ABS(SEC2(KPARP,2)-SEC(KPARP,2)**2*FNT))
      ERR=ERR1+ERR2
      WRITE(26,3008) FB,ERR
      FA=PRIM(3)*FNT
      ERR=3.0D0*FNT*SQRT(ABS(PRIM2(3)-PRIM(3)**2*FNT))
      WRITE(26,3009) FA,ERR
C
      WRITE(26,3010)
     1 WSEC(1,1),WSEC(2,1),WSEC(3,1),WSEC2(1,1),WSEC2(2,1),WSEC2(3,1),
     1 WSEC(1,2),WSEC(2,2),WSEC(3,2),WSEC2(1,2),WSEC2(2,2),WSEC2(3,2),
     1 WSEC(1,3),WSEC(2,3),WSEC(3,3),WSEC2(1,3),WSEC2(2,3),WSEC2(3,3)
C
C  ****  Average energies deposited in bodies..
C
      WRITE(26,3011)
      DO KB=1,NBODY
        IF(MATER(KB).NE.0) THEN
          QER=3.0D0*DF*SQRT(ABS(TDEBO2(KB)-TDEBO(KB)**2*DF))
          QAV=TDEBO(KB)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(26,3012) KB,QAV,QER,EFFIC
        ENDIF
      ENDDO
C
C  ****  Average energies 'collected' by impact detectors.
C
      IF(NDIDEF.GT.0) THEN
        WRITE(26,3013)
        DO KD=1,NDIDEF
          QER=3.0D0*DF*SQRT(ABS(TDID2(KD)-TDID(KD)**2*DF))
          QAV=TDID(KD)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(26,3014) KD,QAV,QER,EFFIC
        ENDDO
      ENDIF
C
C  ****  Average deposited energies in energy-deposition detectors.
C
      IF(NDEDEF.GT.0) THEN
        WRITE(26,3015)
        DO KD=1,NDEDEF
          QER=3.0D0*DF*SQRT(ABS(TDED2(KD)-TDED(KD)**2*DF))
          QAV=TDED(KD)*DF
          IF(QER.GT.1.0D-10*ABS(QAV)) THEN
            EFFIC=QAV**2/((QER/3.0D0)**2*TSIM)
          ELSE
            EFFIC=0.0D0
          ENDIF
          WRITE(26,3014) KD,QAV,QER,EFFIC
        ENDDO
      ENDIF
C
C  ****  Detector efficiencies.
C
      IF(NDIDEF.GT.0) THEN
        WRITE(26,3016)
        DO KD=1,NDIDEF
          SUM=0.0D0
          ESUM=0.0D0
          DO J=1,NDICH(KD)
            YERR=3.0D0*SQRT(ABS(DIT2(KD,J)-DIT(KD,J)**2*DF))
            YAV=MAX(DIT(KD,J)*DF,1.0D-35)
            YERR=MAX(YERR*DF,1.0D-35)
            SUM=SUM+YAV
            ESUM=ESUM+YERR
          ENDDO
          WRITE(26,3017) KD,SUM,ESUM
        ENDDO
      ENDIF
C
      IF(NDEDEF.GT.0) THEN
        WRITE(26,3018)
        DO KD=1,NDEDEF
          SUM=0.0D0
          ESUM=0.0D0
          DO J=1,NDECH(KD)
            YAV=DET(KD,J)*DF
            YERR=3.0D0*SQRT(ABS(YAV*(1.0D0-YAV))*DF)
            SUM=SUM+YAV
            ESUM=ESUM+YERR
          ENDDO
          WRITE(26,3017) KD,SUM,ESUM
        ENDDO
      ENDIF
C
      WRITE(26,3030) ISEED1,ISEED2
      WRITE(26,'(/3X,''***  END  ***'')')
      WRITE(26,'(/3X,72(''-''))')
      CLOSE(26)
C
      RETURN
      END


C  *********************************************************************
C                       SUBROUTINE GCONE
C  *********************************************************************
      SUBROUTINE GCONE(UF,VF,WF)
C
C  This subroutine samples a random direction uniformly within a cone
C  with central axis in the direction (THETA,PHI) and aperture ALPHA.
C  Parameters are initialised by calling subroutine GCONE0.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      PARAMETER (PI=3.1415926535897932D0, TWOPI=2.0D0*PI)
C  ****  Parameters for sampling directions within a cone.
      COMMON/CGCONE/CPCT,CPST,SPCT,SPST,SPHI,CPHI,STHE,CTHE,CAPER
C
      EXTERNAL RAND
C  ****  Define a direction relative to the z-axis.
      WT=CAPER+(1.0D0-CAPER)*RAND(1.0D0)
      DF=TWOPI*RAND(2.0D0)
      SUV=SQRT(1.0D0-WT*WT)
      UT=SUV*COS(DF)
      VT=SUV*SIN(DF)
C  **** Rotate to the beam axis direction.
      UF=CPCT*UT-SPHI*VT+CPST*WT
      VF=SPCT*UT+CPHI*VT+SPST*WT
      WF=-STHE*UT+CTHE*WT
C  ****  Ensure normalisation.
      DXY=UF*UF+VF*VF
      DXYZ=DXY+WF*WF
      IF(ABS(DXYZ-1.0D0).GT.1.0D-14) THEN
        FNORM=1.0D0/SQRT(DXYZ)
        UF=FNORM*UF
        VF=FNORM*VF
        WF=FNORM*WF
      ENDIF
      RETURN
      END
C  *********************************************************************
C                       SUBROUTINE GCONE0
C  *********************************************************************
      SUBROUTINE GCONE0(THETA,PHI,ALPHA)
C
C  This subroutine defines the parameters for sampling random directions
C  uniformly within a cone with axis in the direction (THETA,PHI) and
C  aperture ALPHA (in rad).
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
C  ****  Parameters for sampling directions within a cone.
      COMMON/CGCONE/CPCT,CPST,SPCT,SPST,SPHI,CPHI,STHE,CTHE,CAPER
C
      CPCT=COS(PHI)*COS(THETA)
      CPST=COS(PHI)*SIN(THETA)
      SPCT=SIN(PHI)*COS(THETA)
      SPST=SIN(PHI)*SIN(THETA)
      SPHI=SIN(PHI)
      CPHI=COS(PHI)
      STHE=SIN(THETA)
      CTHE=COS(THETA)
      CAPER=COS(ALPHA)
      RETURN
      END


C  *********************************************************************
C                       SUBROUTINE RDPSF
C  *********************************************************************
      SUBROUTINE RDPSF(IUNIT,NSHI,ISEC,KODEPS)
C
C  This subroutine reads the phase-space file (psf). Blank lines and
C  lines starting with the pound sign (#) are considered as comments and
C  are ignored.
C
C  The reading of a new psf is initiated by calling subroutine RDPSF
C  with KODEPS=0. If the psf contains some particles, the oputput value
C  of KODEPS is set equal to 1. In subsequent calls to subroutine RDPSF,
C  the output value KODEPS=1 indicates that a valid record has been read
C  and that the state variables of a particle have been loaded in common
C  TRACK. The output value of ISEC is 1 if the psf contains more
C  particles from the current shower, and 0 otherwise. That is, when
C  ISEC=0 the next particle in the psf belongs to a new shower. The
C  output value KODEPS=-1 indicates that all particle records in the psf
C  have been read (or that the psf was empty). Note that when KODEPS=-1,
C  the contents of common TRACK remains unchanged.
C
C  To reduce disk-access time, particle records are read in bunches and
C  stored in a buffer. The buffer size (number of particles in a bunch)
C  is defined by the parameter NRBUFF.
C
C  To verify that the input psfs are read correctly, uncomment the lines
C  with 'CALL WRPSF' (which write the read particle records in an output
C  file, UNIT=13). You should also add a sentence 'CALL WRPSF(13,0,1)'
C  at the end of the main program, which forces the writting of particle
C  records that may remain in the buffer and closes the output file.
C  This file should contain all the records read from the psf files.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
C
      PARAMETER (NRBUFF=1000)  ! Buffer size.
      CHARACTER PSFR(NRBUFF)*136
      SAVE PSFR
C  ****  Main-PENELOPE common.
      PARAMETER (MAXMAT=10)
      COMMON/TRACK/E,X,Y,Z,U,V,W,WGHT,KPAR,IBODY,MAT,ILB(5)
C
      SAVE E0,X0,Y0,Z0,U0,V0,W0,WGHT0,KPAR0,ILB10,ILB20,ILB30,ILB40,
     1  NSHI0,ILAST,IRD,IEOF
C
C  ****  Initialisation (first call after opening the psf).
C
      IF(KODEPS.EQ.0) THEN
        NSHI=0
        ISEC=0
        IEOF=0
        DO I=1,NRBUFF
         PSFR(I)='#'  ! Identifies empty records.
        ENDDO
        READ(IUNIT,'(A)',END=10,ERR=10) (PSFR(I),I=1,NRBUFF)
        GO TO 11
   10   CONTINUE
        IEOF=1
   11   CONTINUE
C
        IRD=0
   20   CONTINUE
        IF(IRD.GE.NRBUFF) THEN
          IF(IEOF.EQ.1) THEN
            KODEPS=-1  ! End of file.
            RETURN
          ENDIF
          DO I=1,NRBUFF
           PSFR(I)='#'  ! Identifies empty records.
          ENDDO
          READ(IUNIT,'(A)',END=21,ERR=21) (PSFR(I),I=1,NRBUFF)
          GO TO 22
   21     CONTINUE
          IEOF=1
   22     CONTINUE
          IRD=0
        ENDIF
        IRD=IRD+1
        READ(PSFR(IRD),*,ERR=20,END=20) KPAR0,E0,X0,Y0,Z0,U0,V0,W0,
     1    WGHT0,ILB10,ILB20,ILB30,ILB40,NSHI0
        ILAST=0
        KODEPS=1
        RETURN
      ENDIF
C
C  ****  The last particle in the psf has already been loaded.
C
      IF(ILAST.EQ.1) THEN
        NSHI=0
        ISEC=0
        KODEPS=-1  ! End of file.
C       CALL WRPSF(13,NSHI,-1)  ! Uncomment to check psf reading.
        RETURN
      ENDIF
C
C  ****  A read particle is loaded.
C
      E=E0
      X=X0
      Y=Y0
      Z=Z0
      U=U0
      V=V0
      W=W0
      WGHT=WGHT0
      KPAR=KPAR0
      ILB(1)=ILB10
      ILB(2)=ILB20
      ILB(3)=ILB30
      ILB(4)=ILB40
      NSHI=NSHI0
C     CALL WRPSF(13,NSHI,0)  ! Uncomment to check psf reading.
      KODEPS=1
C
C  ****  Read a new particle and keep its state variables in memory.
C        This is needed to identify possible secondary particles that
C        belong to the same shower.
C
   30 CONTINUE
      IF(IRD.GE.NRBUFF) THEN
        IF(IEOF.EQ.1) THEN
          ILAST=1
          ISEC=0
          RETURN
        ENDIF
        DO I=1,NRBUFF
         PSFR(I)='#'  ! Identifies empty records.
        ENDDO
        READ(IUNIT,'(A)',END=31,ERR=31) (PSFR(I),I=1,NRBUFF)
        GO TO 32
   31   CONTINUE
        IEOF=1
   32   CONTINUE
        IRD=0
      ENDIF
      IRD=IRD+1
      READ(PSFR(IRD),*,ERR=30,END=30) KPAR0,E0,X0,Y0,Z0,U0,V0,W0,
     1    WGHT0,ILB10,ILB20,ILB30,ILB40,NSHI0
C
      IF(NSHI0.EQ.0) THEN
        ISEC=1
      ELSE
        ISEC=0
      ENDIF
      RETURN
      END
C  *********************************************************************
C                       SUBROUTINE WRPSF
C  *********************************************************************
      SUBROUTINE WRPSF(IPSFO,NSHI,ICLOSE)
C
C  This subroutine writes particle records in the output phase-space
C  file (psf). To reduce disk-access time, particle records are
C  collected in a buffer and moved to the psf when the buffer is full.
C  The buffer size (number of records) is set by the parameter NRBUFF.
C
C  Particles that remain in the buffer at the end of a simulation run
C  must be transferred to the psf by calling subroutine WRPSF with
C  ICLOSE=1.
C
C  Input parameters:
C     IPSFO ..... output unit.
C     NSHI ...... incremental shower number.
C     ICLOSE .... closing flag, acts only when its value is not 0.
C                 When ICLOSE .GT. 0, particles remaining in the buffer
C                 are transferred to the psf, and the output unit IPSFO
C                 is closed.
C                 If ICLOSE .LT. 0, particles in the buffer are moved to
C                 the psf, but the output unit remains open.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      CHARACTER*10 LC10A,LC10B
C
      PARAMETER (NRBUFF=1000)  ! Buffer size.
      CHARACTER PSFR(NRBUFF)*136
      SAVE PSFR
C  ****  Main-PENELOPE common.
      PARAMETER (MAXMAT=10)
      COMMON/TRACK/E,X,Y,Z,U,V,W,WGHT,KPAR,IBODY,MAT,ILB(5)
C
      DATA NREC/0/
      SAVE NREC
C
      IF(ICLOSE.NE.0) THEN
        IF(NREC.GT.0) THEN
          DO I=1,NREC
            NCHAR=INDEX(PSFR(I),'*')-1
            WRITE(IPSFO,'(A)') PSFR(I)(1:NCHAR)
          ENDDO
        ENDIF
        IF(ICLOSE.GT.0) CLOSE(IPSFO)
        NREC=0
        RETURN
      ENDIF
C
      NREC=NREC+1
      CALL N2CH10(ILB(4),LC10A,NDIGA)
      CALL N2CH10(NSHI,LC10B,NDIGB)
      WRITE(PSFR(NREC),'(I2,1P,8E13.5,I3,I2,I2,1X,A,1X,A,A)')
     1  KPAR,E,X,Y,Z,U,V,W,WGHT,ILB(1),ILB(2),ILB(3),
     2  LC10A(1:NDIGA),LC10B(1:NDIGB),'*'
C
      IF(NREC.EQ.NRBUFF) THEN
        WRITE(IPSFO,'(A)') (PSFR(I)(1:INDEX(PSFR(I),'*')-1),I=1,NREC)
        NREC=0
      ENDIF
C
      RETURN
      END
C  *********************************************************************
C                       SUBROUTINE N2CH10
C  *********************************************************************
      SUBROUTINE N2CH10(N,L,NDIG)
C
C  This subroutine writes an integer number N in a 10-character string
C  L. The number is written at the left, followed by unused blanks. NDIG
C  is the number of decimal digits of N.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      CHARACTER*10 L,LT
C
      WRITE(LT,'(I10)') N
      DO I=1,10
        IF(LT(I:I).NE.' ') THEN
          IT=I-1
          GO TO 1
        ENDIF
      ENDDO
      IT=9
    1 CONTINUE
      L=LT(IT+1:10)
      NDIG=10-IT
      RETURN
      END


C  *********************************************************************
C                       SUBROUTINE SOURCE
C  *********************************************************************
      SUBROUTINE SOURCE
C
C  Definition of the primary radiation source provided by the user. When
C  KPARP=0, the initial states of primary particles are set by this
C  subroutine, which may use or supersede other definitions in the input
C  file.
C
C  The first call to subroutine SOURCE (when the value of IDEF is equal
C  to 0) should set _all_ the source parameters that are not defined
C  through the input file of PENMAIN. In particular EPMAX (highest
C  energy of the primary particles) should be defined at the first call.
C  This parameter is needed for the initialization of PENELOPE.
C
C  Each subsequent call to SOURCE sets the initial state of a shower,
C  which may consist of several primary particles (e.g., emitted in a
C  cascade of nuclear transitions). The state variables E, X,Y,Z, U,V,W,
C  WGHT, KPAR and ILB(5) of each primary particle are loaded in common
C  TRACK. In the case of polarized photons, the polarization state
C  (Stokes parameters) and the IPOL flag are loaded in common STOKES.
C  Accompanying primary particles are sent to the secondary stack (by
C  calling subroutine STORES of the PENELOPE package); these particles
C  must be marked with ILB(1)=-1 to be treated as proper primary
C  particles by subroutine SHOWER. Since subroutine STORES gets
C  information through the common blocks TRACK and STOKES, the
C  accompanying particles should be defined first. The last particle
C  defined, just before returning control to the calling program, is
C  loaded directly in commons TRACK and STOKES.
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z), INTEGER*4 (I-N)
      INCLUDE 'pmcomms.f' ! Includes the following two common blocks:
C     COMMON/TRACK/E,X,Y,Z,U,V,W,WGHT,KPAR,IBODY,MAT,ILB(5)
C     COMMON/STOKES/SP1,SP2,SP3,IPOL  ! Do not remove the comments!
      DIMENSION ILBS(5)
      EXTERNAL RAND
C  ****  Save IDEF and all parameters needed to set the initial states.
      SAVE IDEF,E1,E2
      DATA IDEF/0/
C
C  ****  Define the source characteristics.
C
      IF(IDEF.EQ.0) THEN  ! Example: 60-Co source, two gamma rays.
        E1=1.17E6
        E2=1.33E6
        EPMAX=E1+E2+1.0D0  ! Note: for positrons add 5.12D5.
        IDEF=1
        RETURN
      ENDIF
C
C  ************  Set the initial states of a new shower.
C
C  ----  Initial position ...
      IF(LEXSRC) THEN
        IF(LEXBD) THEN
          NTRIAL=0
   10     CONTINUE
          X=SX0+(RAND(1.0D0)-0.5D0)*SSX
          Y=SY0+(RAND(2.0D0)-0.5D0)*SSY
          Z=SZ0+(RAND(3.0D0)-0.5D0)*SSZ
          CALL LOCATE
          NTRIAL=NTRIAL+1
          IF(NTRIAL.GT.200) THEN
            WRITE(26,'(3X,''WARNING: the sampling of initial '',
     1        ''positions may be very inefficient.'')')
            WRITE(6,'(3X,''WARNING: the sampling of initial '',
     1        ''positions may be very inefficient.'')')
          ENDIF
          IF(IXSBOD(IBODY).EQ.0) GO TO 10
        ELSE
          X=SX0+(RAND(1.0D0)-0.5D0)*SSX
          Y=SY0+(RAND(2.0D0)-0.5D0)*SSY
          Z=SZ0+(RAND(3.0D0)-0.5D0)*SSZ
        ENDIF
      ELSE
        X=SX0
        Y=SY0
        Z=SZ0
      ENDIF
C
C  ************  First gamma ray (stored in the secondary stack).
C
      KPARS=2
      ES=E1
C  ----  Initial direction ...
      IF(LSCONE) THEN
        CALL GCONE(US,VS,WS)  ! Conical beam.
      ELSE
        WS=CTHL+RAND(4.0D0)*DCTH  ! Rectangular beam.
        UV=SQRT(1.0D0-WS*WS)
        PHI=PHIL+RAND(5.0D0)*DPHI
        US=UV*COS(PHI)
        VS=UV*SIN(PHI)
      ENDIF
      WGHTS=1.0D0
C  ****  The flag ILBS(1)=-1 indicates that the particle is a primary
C  one, i.e., that its energy does not have to be subtracted from the
C  site.
      ILBS(1)=-1
      ILBS(2)=0
      ILBS(3)=0
      ILBS(4)=0
      ILBS(5)=0
      IPOL=0
      CALL STORES(ES,X,Y,Z,US,VS,WS,WGHTS,KPARS,ILBS,IPOL)
C
C  ************  Second gamma ray (ready to be tracked).
C
      KPAR=2
      E=E2
C  ----  Initial direction ...
      IF(LSCONE) THEN
        CALL GCONE(U,V,W)  ! Conical beam.
      ELSE
        W=CTHL+RAND(4.0D0)*DCTH  ! Rectangular beam.
        UV=SQRT(1.0D0-W*W)
        PHI=PHIL+RAND(5.0D0)*DPHI
        U=UV*COS(PHI)
        V=UV*SIN(PHI)
      ENDIF
      WGHT=1.0D0
      ILB(1)=1  ! Identifies primary particles.
      ILB(2)=0
      ILB(3)=0
      ILB(4)=0
      ILB(5)=0
      IPOL=0
      RETURN
      END
