% OFDM RX support routines
%
%

1;

function payload = rx_symbol(fp, tsymb, sidx, size, cpsize, nshift)
	%printf("\tProcessing symbol %d size %d CP %d\n", sidx, size, cpsize);

	tsymb = tsymb(cpsize:end);
	fsymb = fft(tsymb, size);
	if (sidx == 1)
	subplot(2,1,2);
	plot(real(fsymb), imag(fsymb), 'x');
	end

	pidx = 0;
	idx = fp.fsc-1;
	payload = zeros(1, fp.symb_payload_length);
	for i=1:fp.fsc
	if (idx >= size)
		idx-=size;
	end
	if ((mod(idx, 4))!= nshift)
		payload(++pidx) = fsymb(++idx);
	end
	end

end


function rx_payload = rx_frame(rxf, cfg, fp)
disp("Frame reception");

size = cfg.ofdm_symbol_size;
cp0 = fp.cp0_length;
cp = fp.cp_length;
tsize = size+cp;
nshift = cfg.nshift;
rx_payload = [];

	for sbf=1:fp.subframes_per_frame
	for slot=1:fp.slots_per_subframe
		tsymb = rxf(1:tsize);
		payload = rx_symbol(fp, tsymb, 1, size, cp0, nshift);
		rx_payload = [rx_payload, payload];
	for symb=2:fp.symbols_per_slot
	
		tsymb = rxf((symb-1)*tsize:symb*tsize);
		payload = rx_symbol(fp, tsymb, symb, size, cp, nshift);
		rx_payload = [rx_payload, payload];
	
	end
	end
	end

end
