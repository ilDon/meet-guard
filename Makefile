.PHONY: build test app dmg release run clean

build:
	swift build

test:
	swift test

app:
	./Scripts/build-app.sh debug

dmg:
	./Scripts/build-dmg.sh release

release:
	./Scripts/release.sh $(VERSION)

run: app
	open .build/app/MeetGuard.app

clean:
	rm -rf .build
