M = 16;
numSymbols = 1e5;
EbN0_db = 0:2:20;
EbN0 = EbN0_db - 10*log10(log2(M));

numSNR = length(EbN0_db);
SER = zeros(1,numSNR);

gainImabalance = 0.1;
phaseMismatch = 0.05;
dcOffsetI = 0.05;
dcOffsetQ = 0.05;

for i = 1:numSNR
   dataSymbols = randi([0 M-1], numSymbols, 1);
   
   modulatedSignal = qammod(dataSymbols, M, 'UnitAveragePower', true);
   
   I = real(modulatedSignal);
   Q = imag(modulatedSignal);
   recievedSignal = (1 + gainImabalance)*I + 1i*(1 - gainImabalance)*Q;
   
   recievedSignal = recievedSignal .* exp(1i * phaseMismatch);
   
   recievedSignal = recievedSignal + (dcOffsetI) + (1i * dcOffsetQ);
   
   recievedSignal = awgn(recievedSignal, EbN0_db(i), 'measured');
   
   demodulatedSignal = qamdemod(recievedSignal, M, 'UnitAveragePower', true);
   
   SER(i) = sum(dataSymbols ~= demodulatedSignal) / numSymbols;
end

figure;

semilogy(EbN0, SER, 'b-o');
title('SER vs E_b/N_0 for 16-QAM with Receiver Impairments');
xlabel('Eb/N0 in db');
ylabel('Symbol Error Rate (SER)')
grid on;

fprintf('SNR(db)   SER\n');
fprintf('-------   ------');

for j = 1:numSNR
   fprintf('%8.2f   %e\n', EbN0_db(i), SER(i));
end

scatterplot(recievedSignal);
title('Received Signal Constellation with Receiver Impairments (SNR = 20 dB)');
grid on;
