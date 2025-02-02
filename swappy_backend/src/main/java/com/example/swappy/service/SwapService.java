package com.example.swappy.service;

import com.example.swappy.dto.ProductDTO;
import com.example.swappy.dto.SwapRequest;
import com.example.swappy.dto.SwapUpdateRequest;
import com.example.swappy.elasticsearch.repository.ProductElasticRepository;
import com.example.swappy.exception.swap.SwapStatusAlreadyNotPendingException;
import com.example.swappy.exception.swap.UnauthorizedSwapStatusChangeException;
import com.example.swappy.exception.swap.CannotSwapOwnProductException;
import com.example.swappy.jpa.repository.ProductJpaRepository;
import com.example.swappy.model.Product;
import com.example.swappy.model.Swap;
import com.example.swappy.model.SwapStatus;
import com.example.swappy.model.User;
import com.example.swappy.jpa.repository.SwapRepository;
import com.example.swappy.jpa.repository.UserRepository;
import com.google.cloud.firestore.FieldValue;
import com.google.cloud.firestore.Firestore;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;
import com.example.swappy.security.JwtUtil;

import java.util.*;

@Service
public class SwapService {
    private final JwtUtil jwtUtil;

    private final SwapRepository swapRepository;
    private final UserRepository userRepository;
    private final ProductJpaRepository productJpaRepository;
    private final ProductElasticRepository productElasticRepository;

    public SwapService(JwtUtil jwtUtil, SwapRepository swapRepository, UserRepository userRepository, ProductJpaRepository productJpaRepository, ProductElasticRepository productElasticRepository) {
        this.jwtUtil = jwtUtil;
        this.swapRepository = swapRepository;
        this.userRepository = userRepository;
        this.productJpaRepository = productJpaRepository;
        this.productElasticRepository = productElasticRepository;
    }

    // !!!
    public List<Swap> getAllSwaps() {
        return swapRepository.findAll();
    }

    public List<Swap> getSwapsAsSeller(String token) {
        String email = getEmail(token);
        User user = userRepository.findByEmail(email);
        return swapRepository.findAllBySellerId(user.getId());
    }

    public List<Swap> getSwapsAsBuyer(String token) {
        String email = getEmail(token);
        User user = userRepository.findByEmail(email);
        return swapRepository.findAllByBuyerId(user.getId());
    }

    public Swap getSwapById(Long id, String token) {
        String email = getEmail(token);

        User user = userRepository.findByEmail(email);

        Swap swap = swapRepository.findById(id).orElse(null);

        assert swap != null;
        if(user == swap.getSeller()){
            swap.setViewedBySeller(true);
            swapRepository.save(swap);
        }

        return swap;
    }

    public List<Swap> getSwapsByProductId(Long id, String token) {
        String email = getEmail(token);

        User user = userRepository.findByEmail(email);

        Product product = productJpaRepository.findOneById(id);

        if(product.getSeller() == user) {
           return swapRepository.findAllByProductId(id);
        } else {
           return swapRepository.findAllByProductIdAndAndBuyerId(id, user.getId());
        }
    }

    public Swap saveSwap(SwapRequest swapRequest, String token) {

        String email = getEmail(token);

        User buyer = userRepository.findByEmail(email);

        Swap swap = new Swap();
        User seller = userRepository.findOneById(swapRequest.getSellerId());
        Product product = productJpaRepository.findOneById(swapRequest.getProductId());

        if (buyer != seller) {
            swap.setBuyer(buyer);
            swap.setSeller(seller);
            swap.setProduct(product);
            swap.setSwapProductDescription(swapRequest.getSwapProductDescription());
            swap.setSwapProductTitle(swapRequest.getSwapProductTitle());
            swap.setSwapProductImage(swapRequest.getSwapProductImage());
            swap.setEstimatedRetailPrice(swapRequest.getEstimatedRetailPrice());
            swap.setSwapStatus(SwapStatus.PENDING);
            swap.setViewedBySeller(false);
            return swapRepository.save(swap);
        } else {
            throw new CannotSwapOwnProductException("You cannot swap your own items!");
        }
    }
    private void createChatInFirestore(Swap swap) {
        Firestore db = FirestoreClient.getFirestore();

        // Generate chat room ID using buyer and seller IDs
        String chatRoomId = generateChatRoomId(swap.getBuyer().getId(), swap.getSeller().getId());

        // Chat Data
        Map<String, Object> chatData = new HashMap<>();
        chatData.put("participants", Arrays.asList(swap.getBuyer().getId(), swap.getSeller().getId()));
        chatData.put("swapId", swap.getId());
        chatData.put("lastMessage", "");
        chatData.put("lastMessageTime", FieldValue.serverTimestamp());

        // Save chat in Firestore
        db.collection("chats").document(chatRoomId).set(chatData);
    }

    // Generate a unique chat room ID using buyer and seller IDs
    private String generateChatRoomId(Long userId1, Long userId2) {
        List<Long> sortedIds = Arrays.asList(userId1, userId2);
        Collections.sort(sortedIds); // Ensure consistent ID order
        return sortedIds.get(0) + "_" + sortedIds.get(1);
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
                createChatInFirestore(existingSwap);
                Product product = productJpaRepository.findOneById(existingSwap.getProduct().getId());
                product.setIsSold(true);
                productJpaRepository.save(product);
                ProductDTO productDTO = ProductDTO.builder().id(product.getId()).isSold(true).build();
                productElasticRepository.save(productDTO);
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
