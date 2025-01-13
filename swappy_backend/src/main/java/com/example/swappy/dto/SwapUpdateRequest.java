package com.example.swappy.dto;

import com.example.swappy.model.SwapStatus;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Setter
@Getter
public class SwapUpdateRequest {
    private SwapStatus swapStatus;
}
