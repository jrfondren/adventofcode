MMC=mmc -O4 --intermodule-optimization --make

all:: day9 day9b day9c

day9: day9.m marble_mania.m circle.m
	$(MMC) $@

day9b: day9b.m marble_mania2.m circular_list.m
	$(MMC) $@

day9c: day9c.m marble_mania3.m zipper.m
	$(MMC) $@

clean::
	rm -rf Mercury
	rm -fv *.mh *.err *.o *.c *.c_date *.d
	rm -fv day9 day9b day9c
