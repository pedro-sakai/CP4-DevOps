package com.565956.transacoes.controller;

import com.565956.transacoes.model.Transacao;
import com.565956.transacoes.repository.TransacaoRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transacoes")
public class TransacaoController {

    private final TransacaoRepository repository;

    public TransacaoController(TransacaoRepository repository) {
        this.repository = repository;
    }

    // CREATE
    @PostMapping
    public ResponseEntity<Transacao> criar(@Valid @RequestBody Transacao transacao) {
        Transacao salva = repository.save(transacao);
        return ResponseEntity.status(HttpStatus.CREATED).body(salva);
    }

    // READ - todas
    @GetMapping
    public List<Transacao> listar() {
        return repository.findAll();
    }

    // READ - por id
    @GetMapping("/{id}")
    public ResponseEntity<Transacao> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<Transacao> atualizar(@PathVariable Long id, @Valid @RequestBody Transacao dados) {
        return repository.findById(id)
                .map(existente -> {
                    existente.setDescricao(dados.getDescricao());
                    existente.setValor(dados.getValor());
                    existente.setDataTransacao(dados.getDataTransacao());
                    return ResponseEntity.ok(repository.save(existente));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (!repository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
