% Modulation support routines
%
%

1;


% Random symbols generator

function modsymbs = gen_rand_symbols(modtype, length)
	printf("Generating %d %s symbols\n", length, modtype);

	modsymbs = zeros(1,length);
	symbspace = [];
	amps = [];
	card = 0;
	idx = 0;
	BPSK = 0.5;

	switch(modtype)

		case 'BPSK'
			card = 2;
			symbspace = zeros(1,card);
			for b=0:1
				symbspace(b+1) = BPSK*(1-2*b);
			end
			
		case 'QPSK'
			card = 4;
			symbspace = zeros(1,card);
			for b0=0:1
			for b1=0:1
				symbspace(2*b0+b1+1) = (1-2*b0) + 1j*(1-2*b1);
			end
			end
			
		case '16QAM'
			card = 16;
			symbspace = zeros(1,card);
			for a=-1:2:1 
			for b=-1:2:1
				idx = (1+a) + (1+b)/2;  
				amps(idx+1) = -a*(1 + (b*1/2)); 
			end
			end

			for b0=0:1
			for b1=0:1
			for b2=0:1
			for b3=0:1
				symbspace(b0*8+b1*4+b2*2+b3*1+1) = amps(b0*2+b2*1+1) + 1j*amps(b1*2+b3*1+1);
			end
			end
			end
			end

		case '64QAM'
		case '256QAM'

	end

	for i=1:length
		modsymbs(i) = symbspace(randi([1,card]));
	end

end
