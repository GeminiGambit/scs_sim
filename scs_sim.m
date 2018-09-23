% Different subcarrier spacings simulator
%
%

% Configuration parameters
config.numerology = 1;
config.ref_scs = 30e3;
config.carrier_bw = 40e6;
config.n_rb = 106;
config.ofdm_symbol_size = 2048;
config.unused_sc = 636;
config.pilot_ratio = 0.25;
config.pilot_mod = 'QPSK';
config.payload_mod = '16QAM';
config.nshift = 1;

parms.symbols_per_slot = 14;
parms.slots_per_subframe = 2;
parms.subframes_per_frame = 1;
parms.cp0_length = 176;
parms.cp_length = 144;

% Frame parameters

function fp = init_parms(cfg, fp)
	disp("Initializing system parameters");

	fp.symbols_per_frame = fp.subframes_per_frame*fp.slots_per_subframe*fp.symbols_per_slot;
	fp.samples_per_subframe = fp.slots_per_subframe*(fp.symbols_per_slot*(cfg.ofdm_symbol_size+fp.cp_length)
		+ (fp.cp0_length-fp.cp_length));
	fp.samples_per_frame = fp.subframes_per_frame*fp.samples_per_subframe;

	fp.fsc = cfg.ofdm_symbol_size-cfg.unused_sc;

	fp.symb_payload_length = ceil(fp.fsc*(1-cfg.pilot_ratio));
	fp.symb_pilot_length = ceil(fp.fsc*cfg.pilot_ratio);
	fp.payload_length = fp.symbols_per_frame*fp.symb_payload_length;
	fp.pilot_length = fp.symbols_per_frame*fp.symb_pilot_length;

end

function bwp = configure_bwp(cfg, fp, idx, scs, n_rb, rb_offset)
	printf("Configuring BWP %d scs %d n_rb %d rb_offset %d\n", idx, scs, n_rb, rb_offset);

	bwp.idx = idx;
	bwp.scs = scs;
	bwp.n_rb = n_rb;
	bwp.rb_offset = rb_offset;
	bwp.ofdm_symbol_size = cfg.ofdm_symbol_size*(cfg.ref_scs/scs)*(n_rb/cfg.n_rb);
	bwp.slots_per_subframe = fp.slots_per_subframe*(scs/cfg.ref_scs);
	bwp.symbols_per_slot = fp.symbols_per_slot;
	bwp.sc_offset = 12*rb_offset;

end

% Execution script

disp("scs sim");

config
parms = init_parms(config, parms);
bwp1 = configure_bwp(config, parms, 1, 30e3, 53, 0)
bwp2 = configure_bwp(config, parms, 2, 60e3, 53, 53)
bwps = [bwp1, bwp2];

modulation;
modsymbs = gen_rand_symbols(config.payload_mod, parms.payload_length);
pilots = gen_rand_symbols(config.pilot_mod, parms.pilot_length);

ofdm_tx;
txf = gen_frame(bwps, config, parms, modsymbs, pilots);

%ofdm_rx;
%rxf = txf;
%rx_modsymbs = rx_frame(rxf, config, parms);
%subplot(4,1,1);
%plot(real(parms.payload(1:50)),'b');
%subplot(4,1,2);
%plot(real(rx_payload(1:50)),'b');
%subplot(4,1,3);
%plot(imag(parms.payload(1:50)),'r');
%subplot(4,1,4);
%plot(imag(rx_payload(1:50)),'r');

%

