create or replace package cfg  is
    procedure menu_cfg(prm_menu varchar2);
    --
    procedure avisos (prm_order   varchar2 default '2',
				      prm_dir     varchar2 default '1');
    --
    procedure adicionar_aviso(prm_ds_aviso varchar2,
                              prm_dh_inicio varchar2 default to_char(sysdate, 'YYYY-MM-DD'),
                              prm_dh_fim varchar2 default null,
                              prm_tp_usuario varchar2 default 'TODOS',
                              prm_tp_conteudo varchar2 default 'IMAGEM EXTERNA',
                              prm_nm_conteudo varchar2,
                              prm_url_aviso varchar2 default null,
                              prm_tp_origem varchar2 default null,
                              prm_tela_aviso varchar2 default null,
                              prm_usuarios_aviso varchar2 default null);
    --
    procedure remover_aviso(prm_id_aviso number);
    --
    procedure atualizar_aviso ( prm_id_aviso        number,
                                prm_cd_coluna       varchar2,
                                prm_conteudo        varchar2);
    --
    procedure aviso_mostrar_novamente(prm_id_aviso number);
    --
    procedure ir_para_tela_aviso(prm_cd_tela varchar2);
end cfg;
