rm -rf xcelium.d
rm -rf cov_work
xrun \
 -sv \
 -incdir ../sim \
 -incdir ../rtl \
 -f ../filelist/rtl.f \
 -f ../filelist/sim.f \
 -access +rwc \
 -timescale 1ns/1ns \
 -notimingcheck \
 -ALLOWREDEFINITION \
 -xmelabargs cordic_tb\
 -xmsimargs cordic_tb\
 -coverage all 
