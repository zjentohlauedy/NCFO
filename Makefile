CC = cc
CFLAGS = -std=c99 -g
LDFLAGS = -lm

progs = diffhcstats get_player_stats get_record get_stats_by_type lottery print_boxscores print_lineups readhcstats schedule set_lineups


ALL: $(progs)


diffhcstats: diffhcstats.o hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

get_player_stats: get_player_stats.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

get_record: get_record.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

get_stats_by_type: get_stats_by_type.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

lottery: lottery.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

print_boxscores: print_boxscores.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

print_lineups: print_lineups.o hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

readhcstats: readhcstats.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

schedule: schedule.c
	cc -std=c99 -o schedule schedule.c

set_lineups: set_lineups.c hcfiles.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^


lottery.o: lottery.c
	$(CC) $(CFLAGS) -D_BSD_SOURCE -c $<


%.o: %.c hcfiles.h
	$(CC) $(CFLAGS) -c $<


.PHONY: clean
clean:
	rm $(progs) *.o
