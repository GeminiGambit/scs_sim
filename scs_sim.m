% Different subcarrier spacings simulator
%
%

% Configuration parameters
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
	disp("Initializing frame parameters");

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

% Execution script

disp("scs sim");

config
parms = init_parms(config, parms)

modulation;
modsymbs = gen_rand_symbols(config.payload_mod, parms.payload_length);
pilots = gen_rand_symbols(config.pilot_mod, parms.pilot_length);

ofdm_tx;
txf = gen_frame(config, parms, modsymbs, pilots);

ofdm_rx;
rxf = txf;
rx_modsymbs = rx_frame(rxf, config, parms);
%subplot(4,1,1);
%plot(real(parms.payload(1:50)),'b');
%subplot(4,1,2);
%plot(real(rx_payload(1:50)),'b');
%subplot(4,1,3);
%plot(imag(parms.payload(1:50)),'r');
%subplot(4,1,4);
%plot(imag(rx_payload(1:50)),'r');



