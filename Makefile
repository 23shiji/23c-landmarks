update:
	ruby gen.rb
	git add . && git commit -m 'update landmarks' ; git push
	cd ../yipolis-map && git add . && git commit -m 'update landmarks' && git push