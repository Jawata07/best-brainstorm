function OPTIONS = baseline(OPTIONS)
    fs = round( 1 / diff( OPTIONS.mandatory.DataTime([1 2]) ) );
    baseline_length_sample = OPTIONS.optional.baseline_shuffle_windows*fs; % in sample
    no_of_baseline  = floor(length(OPTIONS.optional.Baseline)/baseline_length_sample);
    if no_of_baseline > 1
        Baseline = zeros(size(OPTIONS.optional.Baseline,1), baseline_length_sample, no_of_baseline);
        BaselineTime = zeros(baseline_length_sample, no_of_baseline);

        for k=0:(no_of_baseline-1)
            idx = (1+ k*baseline_length_sample):(baseline_length_sample*(k+1));
            base = OPTIONS.optional.Baseline(:,idx);
            Baseline(:,:,k+1)   = BEst_baseline_from_signal(base);
            BaselineTime(:,k+1) =  OPTIONS.optional.BaselineTime(idx);
        end
    else
        Baseline        = BEst_baseline_from_signal(OPTIONS.optional.Baseline);
        BaselineTime    = OPTIONS.optional.BaselineTime;
    end

    OPTIONS.optional.Baseline = Baseline;
    OPTIONS.optional.BaselineTime = BaselineTime;
    OPTIONS.automatic.Modality.baseline = Baseline;
    OPTIONS.automatic.Modality.BaselineTime = BaselineTime;
end

function baseline = BEst_baseline_from_signal(signal)

    % signal is a Ns x No matrix of data
    % baseline is a Ns x No matrix of synthetic
    % data obtained from the signal. It is obtained
    % from the phase resampling of the Fourier
    % transform of the signal. The baseline
    % thus preserves the spectrum of the signal but
    % destroys the temporal coherence.


    [Ns,No] = size(signal);
    signal  = detrend(signal')';
    qData = zeros(size(signal));
    N = 2^min(10,nextpow2(No));
    randp = 2*pi*rand(1,N);
    randp = 0.5*(randp - flip(randp));
    HANN = hann(N)';
    %%%% RE-Echantillonnage:
    for i = 1:Ns

        uData = resample(signal(i,:),N,No);
        wData = fft(HANN' .* uData',N)';
        wData = wData .* exp(1i*randp);
        wData = real(ifft(wData'));
        qData(i,:) = resample(wData,No,N);
    end
    baseline = qData;


end