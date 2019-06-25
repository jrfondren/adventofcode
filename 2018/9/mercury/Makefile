MMC=mmc -O4 --intermodule-optimization --make

all:: day9 day9b

day9: day9.m marble_mania.m circle.m
	$(MMC) $@

day9b: day9b.m marble_mania2.m circular_list.m
	$(MMC) $@

clean::
	rm -rf Mercury
	rm -fv *.mh *.err
	rm -fv day9 day9b
