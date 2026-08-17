cd ~
if [ -d mrtrix3_tmp ]; then rm -rf mrtrix3_tmp; fi
git clone https://github.com/MRtrix3/mrtrix3.git mrtrix3_tmp
cd mrtrix3_tmp
./configure      # checks for Eigen, Qt5, FFTW, etc.
./build


#toggle script 

cat > ~/use_mrtrix_tmp.sh <<'EOF'
#!/bin/bash
export PATH=$HOME/mrtrix3_tmp/bin:$PATH
echo "MRtrix 3 (tmp) active"
which mrconvert
EOF

cat > ~/use_mrtrix_old.sh <<'EOF'
#!/bin/bash
export PATH=$(echo "$PATH" | awk -v RS=: -v ORS=: '$0!= "'"$HOME/mrtrix3_tmp/bin"'"' | sed 's/:$//')
echo "Reverted to system MRtrix"
which mrconvert
EOF

chmod +x ~/use_mrtrix_*.sh

#swtich to temporary build

source ~/use_mrtrix_tmp.sh

