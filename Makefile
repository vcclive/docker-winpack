all: bin/xvfb-run
	docker build -t vcc/winpack:latest .


bin/xvfb-run:
	wget https://raw.githubusercontent.com/monokrome/xvfb-run/master/xvfb-run -P ./bin
	chmod +x bin/xvfb-run


clean:
	rm -rf bin


.PHONY: clean
