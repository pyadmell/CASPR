classdef WorkspaceStatic < WorkspaceCondition
    %IDFUNCTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected, GetAccess = protected)
        options                         % The options for the wrench closure
    end
    
    methods
        function w = WorkspaceStatic(method)
            w.options               =   optimset('display','off','Algorithm','interior-point-convex');
            if(nargin>0)
                if(strcmp(method,'quad_prog'))
                    w.method = StaticMethods.QP;
                elseif(strcmp(method,'capacity_margin'))
                    w.method = StaticMethods.CMa;
                elseif(strcmp(method,'capability_measure'))
                    w.method = StaticMethods.CMe;
                else
                    msg = 'Incorrect static workspace method set';
                    error(msg);
                end
            % Translate the method into an enum
            else
                w.method = StaticMethods.QP;
            end 
        end
        
        function inWorkspace = evaluate(obj,dynamics)
           if(obj.method == StaticMethods.QP)
               inWorkspace = static_quadprog(dynamics,obj.options);
           elseif(obj.method == StaticMethods.CMa)
               inWorkspace = static_capacity_margin(dynamics,obj.options);
           else
               inWorkspace = static_capability_measure(dynamics,obj.options);
           end
        end
        
        function [isConnected] = connected(obj,workspace,i,j,grid)
            % This file may need a dynamics object added at a later date
            tol = 1e-6;
            isConnected = sum((abs(workspace(:,i) - workspace(:,j)) < grid.delta_q+tol)) + sum((abs(workspace(:,i) - workspace(:,j)-2*pi) < grid.delta_q+tol)) + sum((abs(workspace(:,i) - workspace(:,j)+2*pi) < grid.delta_q+tol)) == grid.n_dimensions;
        end
        
        function setOptions(obj,options)
            obj.options = options;
        end
    end
end