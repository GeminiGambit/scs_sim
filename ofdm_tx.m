% OFDM TX support routines
%
%

1;

% Function for generating an ofdm symbol

function ofdmsymb = gen_ofdm_symb (cfg, fp, cpsize, sidx, modsymbs, pilots)

	size = cfg.ofdm_symbol_size;

	%printf("\tGeneration of OFDM symbol %d size %d CP %d \n", sidx, size, cpsize);

	ofdmsymb = zeros(1, size+cpsize);
	fsymb = zeros(1, size);
	tsymb = zeros(1,size);

	nsc = fp.fsc;
	idx = fp.fsc;

	sbf.modsymbs = modsymbs((sidx-1)*fp.symb_payload_length+1:sidx*fp.symb_payload_length);
	sbf.pilots = pilots((sidx-1)*fp.symb_pilot_length+1:sidx*fp.symb_pilot_length);

		%%Freq domain mapping
	pd_idx = 0;
	pt_idx = 0;

	for i=1:nsc
		if (idx>=size)
			idx-=size;
		end
		if (mod(idx, 4) == cfg.nshift)
			fsymb(++idx) = sbf.pilots(++pt_idx);
		else
			fsymb(++idx) = sbf.modsymbs(++pd_idx);
		end
	end
	if (sidx == 1)
		subplot(2,1,1);
		plot(real(fsymb), imag(fsymb),'x');
	end

		%IFFT + CP
	tsymb=ifft(fsymb, size);
	ofdmsymb = [tsymb(size-cpsize+1:size), tsymb];
	%plot(abs(ofdmsymb));
end

% Function for generating a full frame

function tx = gen_frame(cfg, fp, modsymbs, pilots)

	disp("Frame generation"); 

	tx = [];
	tmp = [];
	cp0 = fp.cp0_length;
	cp = fp.cp_length;
	sidx = 0;

	for sbf=1:fp.subframes_per_frame
	for slot=1:fp.slots_per_subframe
		tmp = gen_ofdm_symb (cfg, fp, cp0, ++sidx, modsymbs, pilots);
		tx = [tx, tmp];
		for symb=2:fp.symbols_per_slot

			tmp = gen_ofdm_symb (cfg, fp, cp, ++sidx, modsymbs, pilots);
			tx = [tx, tmp];

		end
	end
	end

	%plot(abs(tx));
end
