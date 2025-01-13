package com.example.swappy.service;

import com.example.swappy.model.Swap;
import com.example.swappy.repository.SwapRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SwapService {

    private final SwapRepository swapRepository;

    public SwapService(SwapRepository swapRepository) {
        this.swapRepository = swapRepository;
    }

    // !!!
    public List<Swap> getAllSwaps() {
        return swapRepository.findAll();
    }

    public Swap getSwapById(Long id) {
        return swapRepository.findById(id).orElse(null);
    }

    public Swap saveSwap(Swap swap) {
        return swapRepository.save(swap);
    }

    public void deleteSwap(Long id) {
        swapRepository.deleteById(id);
    }
}
