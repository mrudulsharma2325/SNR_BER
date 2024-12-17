clc;
clear all;
close all;

num_bit = 1000;
data = randi([0 1], 1, num_bit);
SNRdB = 0:10;
SNR = 10.^(SNRdB / 10);

BER_unipolarNRZ = zeros(1, length(SNRdB));
BER_unipolarRZ = zeros(1, length(SNRdB));
BER_polarNRZ = zeros(1, length(SNRdB));
BER_polarRZ = zeros(1, length(SNRdB));

for k = 1:length(SNRdB)
    noise_variance = 1 / (2 * SNR(k));
    noise_std_dev = sqrt(noise_variance);

    unipolarNRZ_signal = modulate(data, 'unipolarNRZ');
    noisy_unipolarNRZ = unipolarNRZ_signal + noise_std_dev * randn(size(unipolarNRZ_signal));
    detected_unipolarNRZ = demodulate(noisy_unipolarNRZ, 'unipolarNRZ');
    BER_unipolarNRZ(k) = sum(detected_unipolarNRZ ~= data) / num_bit;

    unipolarRZ_signal = modulate(data, 'unipolarRZ');
    noisy_unipolarRZ = unipolarRZ_signal + noise_std_dev * randn(size(unipolarRZ_signal));
    detected_unipolarRZ = demodulate(noisy_unipolarRZ, 'unipolarRZ');
    BER_unipolarRZ(k) = sum(detected_unipolarRZ ~= data) / num_bit;

    polarNRZ_signal = modulate(data, 'polarNRZ');
    noisy_polarNRZ = polarNRZ_signal + noise_std_dev * randn(size(polarNRZ_signal));
    detected_polarNRZ = demodulate(noisy_polarNRZ, 'polarNRZ');
    BER_polarNRZ(k) = sum(detected_polarNRZ ~= data) / num_bit;

    polarRZ_signal = modulate(data, 'polarRZ');
    noisy_polarRZ = polarRZ_signal + noise_std_dev * randn(size(polarRZ_signal));
    detected_polarRZ = demodulate(noisy_polarRZ, 'polarRZ');
    BER_polarRZ(k) = sum(detected_polarRZ ~= data) / num_bit;
end

figure;
semilogy(SNRdB, BER_unipolarNRZ, '-o', 'DisplayName', 'Unipolar NRZ');
hold on;
semilogy(SNRdB, BER_unipolarRZ, '-s', 'DisplayName', 'Unipolar RZ');
semilogy(SNRdB, BER_polarNRZ, '-^', 'DisplayName', 'Polar NRZ');
semilogy(SNRdB, BER_polarRZ, '-+', 'DisplayName', 'Polar RZ');

BER_th = 0.5 * erfc(sqrt(SNR));
semilogy(SNRdB, BER_th, 'r', 'linewidth', 2.5, 'DisplayName', 'Theoretical BER');

grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Performance of Different Line Coding Schemes for PSK');
legend;
axis([0 10 10^-5 1]);
hold off;

function modulated_signal = modulate(data, line_coding)
    switch line_coding
        case 'unipolarNRZ'
            modulated_signal = data;
        case 'unipolarRZ'
            modulated_signal = repelem(data, 2);
            modulated_signal(2:2:end) = 0;
        case 'polarNRZ'
            modulated_signal = 2 * data - 1;
        case 'polarRZ'
            modulated_signal = repelem(2 * data - 1, 2);
            modulated_signal(2:2:end) = 0;
        otherwise
            error('Unknown line coding scheme');
    end
end

function detected_bits = demodulate(noisy_signal, line_coding)
    switch line_coding
        case 'unipolarNRZ'
            detected_bits = noisy_signal > 0.5;
        case 'unipolarRZ'
            detected_bits = noisy_signal(1:2:end) > 0.5;
        case 'polarNRZ'
            detected_bits = noisy_signal > 0;
        case 'polarRZ'
            detected_bits = noisy_signal(1:2:end) > 0;
        otherwise
            error('Unknown line coding scheme');
    end
end