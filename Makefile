.PHONY: build test app run clean

build:
	swift build

test:
	swift test

app:
	./Scripts/build-app.sh debug

run: app
	open .build/app/MeetGuard.app

clean:
	rm -rf .build
