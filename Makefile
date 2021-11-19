documentation :
	julia --color=yes docs/make.jl
	git add docs/build/
	git commit -m "updating documents"
	git subtree push --prefix docs/build/ origin gh-pages 
