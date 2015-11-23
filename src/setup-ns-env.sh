sudo su cd ns-allinone-2.35/./install;

echo "# LD_LIBRARY_PATH"  >> $HOME/.bashrc;
echo "OTCL_LIB=$(pwd)/ns-allinone-2.35/otcl-1.14" >> $HOME/.bashrc;
echo "NS2_LIB=$(pwd)/ns-allinone-2.35/lib" >> $HOME/.bashrc;
echo "X11_LIB=/usr/X11R6/lib" >> $HOME/.bashrc;
echo "USR_LOCAL_LIB=/usr/local/lib" >> $HOME/.bashrc;
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OTCL_LIB:$NS2_LIB:$X11_LIB:$USR_LOCAL_LIB" >> $HOME/.bashrc;
echo "# TCL_LIBRARY" >> $HOME/.bashrc;
echo "TCL_LIB=$(pwd)/ns-allinone-2.35/tcl8.5.10/library" >> $HOME/.bashrc;
echo "USR_LIB=/usr/lib" >> $HOME/.bashrc;
echo "export TCL_LIBRARY=$TCL_LIB:$USR_LIB" >> $HOME/.bashrc;
echo "# PATH" >> $HOME/.bashrc;
echo "XGRAPH=$(pwd)/ns-allinone-2.35/bin:$(pwd)/ns-allinone-2.35/tcl8.5.10/unix:$(pwd)/ns-allinone-2.35/tk8.5.10/unix" >> $HOME/.bashrc;
echo "#the above two lines beginning from xgraph and ending with unix should come on the same line" >> $HOME/.bashrc;
echo "NS=$(pwd)/ns-allinone-2.35/ns-2.35/" >> $HOME/.bashrc;
echo "NAM=$(pwd)/ns-allinone-2.35/nam-1.15/"  >> $HOME/.bashrc;
echo "PATH=$PATH:$XGRAPH:$NS:$NAM" >> $HOME/.bashrc;
