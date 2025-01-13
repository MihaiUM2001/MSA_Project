package com.example.swappy.controller;

import com.example.swappy.model.Swap;
import com.example.swappy.service.SwapService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/swaps")
public class SwapController {

    private final SwapService swapService;

    public SwapController(SwapService swapService) {
        this.swapService = swapService;
    }

    // !!!
    @GetMapping
    public List<Swap> getAllSwaps() {
        return swapService.getAllSwaps();
    }

    @GetMapping("/{id}")
    public Swap getSwapById(@PathVariable Long id) {
        return swapService.getSwapById(id);
    }

    @PostMapping
    public Swap createSwap(@RequestBody Swap swap) {
        return swapService.saveSwap(swap);
    }

    @PutMapping("/{id}")
    public Swap updateSwap(@PathVariable Long id, @RequestBody Swap updatedSwap) {
        Swap existingSwap = swapService.getSwapById(id);
        if (existingSwap != null) {
            existingSwap.setSwapStatus(updatedSwap.getSwapStatus());
            return swapService.saveSwap(existingSwap);
        }
        return null;
    }

    @DeleteMapping("/{id}")
    public void deleteSwap(@PathVariable Long id) {
        swapService.deleteSwap(id);
    }
}
