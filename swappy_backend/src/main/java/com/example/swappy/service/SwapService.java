package com.example.swappy.service;

import com.example.swappy.dto.SwapRequest;
import com.example.swappy.dto.SwapUpdateRequest;
import com.example.swappy.exception.swap.SwapStatusAlreadyNotPendingException;
import com.example.swappy.exception.swap.UnauthorizedSwapStatusChangeException;
import com.example.swappy.exception.swap.CannotSwapOwnProductException;
import com.example.swappy.model.Product;
import com.example.swappy.model.Swap;
import com.example.swappy.model.SwapStatus;
import com.example.swappy.model.User;
import com.example.swappy.repository.ProductRepository;
import com.example.swappy.repository.SwapRepository;
import com.example.swappy.repository.UserRepository;
import org.springframework.stereotype.Service;
import com.example.swappy.security.JwtUtil;

import java.util.List;

@Service
public class SwapService {
    private final JwtUtil jwtUtil;

    private final SwapRepository swapRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    public SwapService(JwtUtil jwtUtil, SwapRepository swapRepository, UserRepository userRepository, ProductRepository productRepository) {
        this.jwtUtil = jwtUtil;
        this.swapRepository = swapRepository;
        this.userRepository = userRepository;
        this.productRepository = productRepository;
    }

    // !!!
    public List<Swap> getAllSwaps() {
        return swapRepository.findAll();
    }

    public Swap getSwapById(Long id) {
        return swapRepository.findById(id).orElse(null);
    }

    public Swap saveSwap(SwapRequest swapRequest, String token) {

        String email = getEmail(token);

        User buyer = userRepository.findByEmail(email);

        Swap swap = new Swap();
        User seller = userRepository.findOneById(swapRequest.getSellerId());
        Product product = productRepository.findOneById(swapRequest.getProductId());

        if (buyer != seller) {
            swap.setBuyer(buyer);
            swap.setSeller(seller);
            swap.setProduct(product);
            swap.setSwapProductDescription(swapRequest.getSwapProductDescription());
            swap.setSwapProductTitle(swapRequest.getSwapProductTitle());
            swap.setSwapProductImage(swapRequest.getSwapProductImage());
            swap.setEstimatedRetailPrice(swapRequest.getEstimatedRetailPrice());
            swap.setSwapStatus(SwapStatus.PENDING);
            return swapRepository.save(swap);
        } else {
            throw new CannotSwapOwnProductException("You cannot swap your own items!");
        }
    }

    public Swap updateSwap(SwapUpdateRequest swapRequest, Long id, String token) {

        String email = getEmail(token);

        User user = userRepository.findByEmail(email);

        Swap existingSwap = swapRepository.findOneById(id);

        if (swapRequest.getSwapStatus() != null && existingSwap.getSwapStatus() != SwapStatus.PENDING) {
            throw new SwapStatusAlreadyNotPendingException("Swap status already been changed from PENDING!");
        } else {

            if (swapRequest.getSwapStatus() == SwapStatus.DENIED && user == existingSwap.getSeller()) {
                existingSwap.setSwapStatus(swapRequest.getSwapStatus());
                return swapRepository.save(existingSwap);
            } else if (swapRequest.getSwapStatus() == SwapStatus.DENIED) {
                throw new UnauthorizedSwapStatusChangeException("You cannot do this operation as a buyer!");
            }

            if (swapRequest.getSwapStatus() == SwapStatus.ACCEPTED && user == existingSwap.getSeller()) {
                existingSwap.setSwapStatus(swapRequest.getSwapStatus());
                return swapRepository.save(existingSwap);
            } else if (swapRequest.getSwapStatus() == SwapStatus.ACCEPTED) {
                throw new UnauthorizedSwapStatusChangeException("You cannot do this operation as a buyer!");
            }

            if (swapRequest.getSwapStatus() == SwapStatus.CANCELLED && user == existingSwap.getBuyer()) {
                existingSwap.setSwapStatus(swapRequest.getSwapStatus());
                return swapRepository.save(existingSwap);
            } else if (swapRequest.getSwapStatus() == SwapStatus.CANCELLED) {
                throw new UnauthorizedSwapStatusChangeException("You cannot do this operation as a seller!");
            }
        }

        return null;
    }

    public void deleteSwap(Long id) {
        swapRepository.deleteById(id);
    }

    private String getEmail(String token) {
        String email = null;
        String jwt;

        if (token != null && token.startsWith("Bearer ")) {
            jwt = token.substring(7);
            email = jwtUtil.extractUsername(jwt);
        }
        return email;
    }
}
