package com.example.swappy.controller;

import com.example.swappy.dto.SwapRequest;
import com.example.swappy.dto.SwapUpdateRequest;
import com.example.swappy.exception.ErrorResponse;
import com.example.swappy.exception.swap.CannotSwapOwnProductException;
import com.example.swappy.exception.swap.SwapStatusAlreadyNotPendingException;
import com.example.swappy.exception.swap.UnauthorizedSwapStatusChangeException;
import com.example.swappy.model.Swap;
import com.example.swappy.service.SwapService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
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

    @GetMapping("/product/{id}")
    public List<Swap> getSwapsByProductId(@PathVariable Long id, @RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        return swapService.getSwapsByProductId(id, token);
    }

    @PostMapping
    public Swap createSwap(@RequestBody SwapRequest swap, @RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        return swapService.saveSwap(swap, token);
    }

    @PatchMapping("/{id}")
    public Swap updateSwap(@PathVariable Long id, @RequestBody SwapUpdateRequest swapUpdateRequest, @RequestHeader(HttpHeaders.AUTHORIZATION) String token) {
        return swapService.updateSwap(swapUpdateRequest, id, token);
    }


    @DeleteMapping("/{id}")
    public void deleteSwap(@PathVariable Long id) {
        swapService.deleteSwap(id);
    }

    @ExceptionHandler(value = CannotSwapOwnProductException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleCannotSwapOwnProductException(CannotSwapOwnProductException e) {
        return new ErrorResponse(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }

    @ExceptionHandler(value = UnauthorizedSwapStatusChangeException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleUnauthorizedSwapStatusChangeException(UnauthorizedSwapStatusChangeException e) {
        return new ErrorResponse(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }

    @ExceptionHandler(value = SwapStatusAlreadyNotPendingException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ErrorResponse handleSwapStatusAlreadyNotPendingException(SwapStatusAlreadyNotPendingException e) {
        return new ErrorResponse(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }
}
