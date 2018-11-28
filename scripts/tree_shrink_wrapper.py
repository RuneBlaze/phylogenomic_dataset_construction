"""
Detects and trim abnormally long branches using TreeShrink

TreeShrink must be installed and on path
Phyx (pxrr) must be installed and on path

"""

import sys, os, shutil

def trim(DIR,tree_file_ending,q):

	if os.path.isabs(DIR) == False: DIR = os.path.abspath(DIR)
	if DIR[-1] != "/": DIR += "/"
	
	filecount = 0
	
	#runs treeshrink
	for i in os.listdir(DIR):
		if i.endswith(tree_file_ending):
			print i
			filecount += 1
			cmd= ["treeshrink.py","-i", DIR+i ,"-o", i+".ts", "-c","-m per-gene", "-q"+str(q), "-d",DIR+i+".ts_dir"]
			print (" ".join(cmd))
			os.system(" ".join(cmd))
	
	#moves output files to DIR and delete treeshrink individual folders
	for j in os.listdir(DIR):
		if j.endswith(".ts_dir"):
			source = DIR+j
			dest = DIR
			files = os.listdir(source)
			for f in files:
				shutil.move(source+"/"+f, dest)
			shutil.rmtree(DIR+j)
	
	#removes single quotes from tip labels from treeshrink output trees
	for k in os.listdir(DIR):
		if k.endswith(".ts"):
			with open(DIR+k, 'r+') as f:
				content = f.read()
				f.seek(0)
				f.truncate()
				f.write(content.replace("'", ""))
			f.close()
	
	#unroot treeshrink ouput trees
	for l in os.listdir(DIR):
		if l.endswith(".ts"):
			cmd= ["pxrr","-u","-t", DIR+l,"-o",DIR+l+".tt"]
			print (" ".join(cmd))
			os.system(" ".join(cmd))			
			
	#delete ts files
	for m in os.listdir(DIR):
			if m.endswith(".ts"):
    				os.remove(DIR+m)
            
            
	assert filecount > 0, \
		"No file end with "+tree_file_ending+" found in "+DIR
			
			
if __name__ == "__main__":
	if len(sys.argv) != 4:
		print "python tree_shrink_wrapper.py DIR tree_file_ending quantile"
		sys.exit(0)

	DIR,tree_file_ending,q = sys.argv[1:]
	trim(DIR,tree_file_ending,q)


