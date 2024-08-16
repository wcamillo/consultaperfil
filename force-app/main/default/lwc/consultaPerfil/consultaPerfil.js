import { LightningElement, track } from 'lwc';
import getUsersWithDetails from '@salesforce/apex/UserController.getUsersWithDetails';

export default class ConsultaPerfil extends LightningElement {
    @track searchKey = '';
    @track users = [];
    @track error;

    // Função para lidar com a mudança no campo de busca
    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
    }
    // Função para buscar usuários pelo nome
    handleSearch() {
        getUsersWithDetails({ userName: this.searchKey })
            .then(data => {
                console.log('Data received from Apex:', data);
                this.users = data ? data.map(user => ({
                    ...user,
                    Email: user.Email || 'N/A', // Corrigido para lidar com Email como string
                    Role: user.Role || 'N/A', // Adicionado: Lida com o campo Role
                    Manager: user.Manager ? user.Manager.Name : 'N/A', // Adicionado: Lida com o campo Manager
                    Profile: user.ProfileName || 'N/A', // Corrigido para usar ProfileName
                    PermissionSets: user.PermissionSets ? user.PermissionSets.join(', ') : '',
                    activeIcon: user.IsActive ? 'utility:success' : 'utility:error',
                    iconClass: user.IsActive ? 'success-icon' : 'error-icon',
                    iconSize: 'x-small', // Ajustado para usar tamanho fixo
                    iconVariant: user.IsActive ? 'success' : 'error' // Definido o variant
                })) : [];
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.body.message; // Corrigido para extrair a mensagem do erro
                this.users = [];
            });
    }

    }

